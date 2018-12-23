warning off;
% Normalize the columns of A to have unit l^2-norm.
for i = 1 : size(fbgTestImgs,2)
    fbgTestImgs(:,i) = fbgTestImgs(:,i) / norm(fbgTestImgs(:,i));
end

% fbgTrainImg = single(fbgTrainImgs);
% fbgTestImgs = single(fbgTestImgs);

testLen = size(fbgTestImgs,2);

resultIds = zeros(1,length(testLen));
correctLabel = 0;

batch = 1;
try, batch = eval(opt.algorithm.l2.batchSize); end
if ischar(batch), batch = str2double(batch); end

% 
% tau = 0.01; % Best >128 friends accuracy
% tau = 0.000001;
% tau = 0.1; % Best overall accuracy
% tau = 0.25; % Best PR curve
% tau = 0.4;
% tau = 0.175;
% tau = 0.001; % TAKES FOREVER!
% tau = 0.3;
% tau = 0.22;
% 
% tau = 0.01;
% 
% SRC_L1LS = 0;
% SRC_GPSR = 2;
% SRC_YALL1 = 1;
% SRC_NS = 3;         % Nearest Subspace Implementation of SRC
% SRC_L2 = 4;         % L2 Norm instead of l1-minimization
% SRC_OCC = 5;
% SRC_RWL2 = 6;
% SRC_L2_NS = 7;
% 
% fbgSRCNormalize = 0;
% fbgSRCMethod = SRC_GPSR;%SRC_L2;%SRC_GPSR;

% if fbgSRCMethod == SRC_YALL1
%     [Q, R] = qr(fbgTrainImgs',0);
%     fbgTrainImgs = Q';% b = R'\b;
% elseif fbgSRCMethod == SRC_L1LS || fbgSRCMethod == SRC_L2
%     Ainv = pinv(fbgTrainImgs);
% elseif fbgSRCMethod == SRC_OCC
%     fbgTrainImgs = [fbgTrainImgs, eye(length(fbgTrainImgs(:,1)))];
%     idx2 = find([zeros(length(fbgTrainIds),1); ones(length(fbgTrainImgs(:,1)),1)]);
% end


allClasses = unique(fbgTrainIds);
% numClassTrainImgs = zeros(length(allClasses),1);
minResiduals = zeros(testLen,1);

% for i = 1 : length(allClasses)
%     numClassTrainImgs(i) = sum(fbgTrainIds == allClasses(i));
% end

% classes = unique(fbgTrainIds);
% 
% classNorm = zeros(1,length(classes));
% cacheIdx = {};
% for j = 1 : length(classes)
%     classNorm(j) = sum(fbgTrainIds == classes(j));
%     cacheIdx{j} = find(fbgTrainIds == classes(j));
%     cacheAinv{j} = pinv(fbgTrainImgs(:,cacheIdx{j}));
% end

fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
cdistMatrix = zeros(length(fbgTestIds)+1,length(classes)+2);

for m = [1:batch:testLen testLen]
	len = min([batch-1, testLen-m]);
	
	if length(fbgTestIds) == 0 || len < 0, break; end
    
    residuals = zeros(len+1,length(classes));
    
    for j = 1:length(classes)
        idx = cacheIdx{j};
        xp = cacheAinv{j}* fbgTestImgs(:,m:m+len);
        residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp).^2,1));
    end
    
%     % Verify batch is working correctly
%     for k =0:len
%         Rr = zeros(1,length(classes));
%         for j = 1 : length(classes)
%             idx = cacheIdx{j};
%             xp = cacheAinv{j}* fbgTestImgs(:,m+k);
%             Rr(j) = norm(fbgTestImgs(:,m+k) - fbgTrainImgs(:,idx) * xp);
%         end
%         d = norm(Rr - residuals(k+1,:));
%         assert(d < 1e-4);
%     end

	cdistMatrix(m:m+len,1:length(classes)) = residuals;

	% Minimum residual error indicates to which class the object (face)
	% belongs.
	[val, ind] = min(residuals,[],2);
	minResiduals(m:m+len) = val;
	resultIds(m:m+len) = classes(ind);

	correctLabel = correctLabel + sum(resultIds(m:m+len) == fbgTestIds(m:m+len)');
	fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', m+len, length(fbgTestIds));
end

distMatrix = [minResiduals resultIds' fbgTestIds];
cdistMatrix(1:end-1,end-1) = resultIds';
cdistMatrix(1:end-1,end) = fbgTestIds;
cdistMatrix(end,1:length(classes)) = classes;

fbgAccuracy = 100 * correctLabel / testLen;

return;










for i = 1 : testLen
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, length(fbgTestIds));

    residuals = zeros(1,length(classes));
    % Compute the residuals
    for j = 1 : length(classes)
        idx = cacheIdx{j};
        xp = cacheAinv{j}* fbgTestImgs(:,i);
        residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs(:,idx) * xp);
    end
    
    % Minimum residual error indicates to which class the object (face)
    % belongs.
    [val, ind] = min(residuals);
    minResiduals(i) = val;
    resultIds(i) = classes(ind);

    if resultIds(i) == fbgTestIds(i)
        correctLabel = correctLabel + 1;
    end

% 	fprintf('Accuracy: %0.2f (%d out of %d)\n', correctLabel / i * 100, correctLabel, i);
end

if fbgSRCMethod == SRC_OCC
    fbgTrainImgs = fbgTrainImgs(:,1:end-length(fbgTrainImgs(:,1)));
end

distMatrix = [minResiduals resultIds' fbgTestIds];
cdistMatrix(1:end-1,end-1) = resultIds';
cdistMatrix(1:end-1,end) = fbgTestIds;
cdistMatrix(end,1:length(classes)) = classes;

fbgAccuracy = 100 * correctLabel / testLen;

warning on;