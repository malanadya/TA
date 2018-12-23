batch = 1;
try, batch = opt.algorithm.nn.batchSize; end;
topRes = 0;
try, topRes = opt.algorithm.src.prune.topRes; end
lsrcDown = 0;
try, lsrcDown = opt.algorithm.src.prune.lsrcDown; end

if ~exist('testWeights', 'var') & exist('fbgTestImgs', 'var')
    clearTestImgs = 1;
    testWeights = fbgTestImgs;
end
if ~exist('trainWeights', 'var') & exist('fbgTrainImgs', 'var')
    clearTrainImgs = 1;
    trainWeights = fbgTrainImgs;
end

if batch == 1
    testlen = size(testWeights,2);
    trainlen = size(trainWeights,2);
    index = zeros(testlen,topX);
    resultIds = zeros(testlen,topX);
    resultDist = zeros(testlen,topX);
    x2 = sum(testWeights.^2,1)';
    y2 = sum(trainWeights.^2,1);
    if fbgDistanceMetric
        w = inv(cov(trainWeights'));
    end

    classes = unique(fbgTrainIds);
    cdistMatrix = zeros(length(fbgTestIds)+1,length(classes)+2);

    fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
    for i = 1:testlen
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, testlen);
        if fbgDistanceMetric
            z = mahaldist(testWeights(:,i)', trainWeights', w);
        else
            z = testWeights(:,i)'*trainWeights;
            z = repmat(x2(i),1,trainlen) + y2 - 2*z;
            z(z < 0) = 0;
            %z = x2 + repmat(y2(i),1,trainlen) - 2*z;
            %[C, index(i)] = min(z);
        end
        for j = 1:length(classes)
            cdistMatrix(i,j) = min(z(fbgTrainIds == classes(j)));
        end
        for j = 1:topX
            [best, index(i, j)] = min(z);
            resultIds(i, j) = fbgTrainIds(index(i, j));
            resultDist(i, j) = best;
            z(index(i, j)) = Inf; % Remove best

            % Keep searching until we have a new person because we the first
            % two hits might be the same person (wrong code)
            if j > 1
                while sum(resultIds(i, 1:j-1) == resultIds(i, j)) > 0
                    [best, index(i, j)] = min(z);
                    resultIds(i, j) = fbgTrainIds(index(i, j));
                    resultDist(i, j) = best;
                    z(index(i, j)) = Inf; % Remove best		
                end
            end
        end	
    end

    cdistMatrix(1:end-1,end-1) = resultIds';
    cdistMatrix(1:end-1,end) = fbgTestIds;
    cdistMatrix(end,1:length(classes)) = classes;

    [r,c] = size(resultDist);
    distMatrix = zeros(r,c*2+1);
    distMatrix(:,1:c) = resultDist;
    distMatrix(:,c+1:2*c) = resultIds;
    distMatrix(:,end) = fbgTestIds;
    if exist('fbgMethod', 'var')
        save([fbgStatsFolder '/' fbgMethod '/' fbgDataset '_dist.txt'], 'distMatrix', '-ASCII');
    end

    % Store the number of correct
    if topX > 1
        resultMatrix = (resultIds == repmat(fbgTestIds, 1, topX));
        results = max(resultMatrix, [], 2);
    else
        resultMatrix = (resultIds == fbgTestIds);
        results = max(resultMatrix, [], 2);
    end
else
    testlen = size(testWeights,2);
    trainlen = size(trainWeights,2);
    
    classes = unique(fbgTrainIds);
    cacheIdx = {};
    for j = 1:length(classes)
        cacheIdx{j} = find(fbgTrainIds == classes(j));
    end
    
    cdistMatrix = zeros(length(fbgTestIds)+1,length(classes)+2);
    resultDist = zeros(length(fbgTestIds),1);
    resultIds = zeros(length(fbgTestIds),1);
    if topRes > 0
        bestX = zeros(topRes, length(fbgTestIds));
    end
    
    fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
    trainWeightsSqr = sum(trainWeights.^2)';
    for i = [1:batch:testlen testlen]
        len = min([batch-1, testlen-i]);
        if len < 0 || len+i == 0,	break; end
        
        %z = distSqr(testWeights(:,i:i+len), trainWeights);
        z = distSqr_fast(trainWeights, trainWeightsSqr, testWeights(:,i:i+len))';
        if topRes
            [sv,si] = sort(z, 2, 'ascend');
            bestX(:,i:i+len) = si(:,1:topRes)';
        end
        
        % LSRC doesn't actually need things per class
        if ~lsrcDown || strcmp(opt.algorithm.name, 'nn') || strcmp(opt.algorithm.name, 'pca_nn')
            
%            % If we want to KNN where K != 1, uncomment this code 
%             [sv,si] = sort(z,2);
%             K = 5;
%             resultDist(i:i+len) = mean(sv(:,1:K),2);
%             ids = reshape(fbgTrainIds(si(:,1:K)), size(si(:,1:K)));
%             resultIds(i:i+len) = mode(ids,2);
            
            [resultDist(i:i+len), ids] = min(z,[],2);
            resultIds(i:i+len) = fbgTrainIds(ids);

            for j = 1:length(classes)
                cdistMatrix(i:i+len,j) = min(z(:,cacheIdx{j}),[],2);
            end
        end
        
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, testlen);
    end
    
    cdistMatrix(1:end-1,end-1) = resultIds';
    cdistMatrix(1:end-1,end) = fbgTestIds;
    cdistMatrix(end,1:length(classes)) = classes;
    
    distMatrix = zeros(testlen,3);
    distMatrix(:,1) = resultDist;
    distMatrix(:,2) = resultIds;
    distMatrix(:,3) = fbgTestIds;
end


results = fbgTestIds == resultIds;
fbgAccuracy = 100 * sum(results) / size(fbgTestIds,1);