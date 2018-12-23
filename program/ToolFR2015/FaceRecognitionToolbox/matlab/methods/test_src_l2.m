% Normalize the columns of A to have unit l^2-norm.
% skipNorm = 0;
% try, skipNorm = opt.algorithm.src.skipPreNorm; end
% if ~skipNorm
    for i = 1 : size(fbgTestImgs,2)
        fbgTestImgs(:,i) = fbgTestImgs(:,i) / norm(fbgTestImgs(:,i));
    end
% end

testLen = size(fbgTestImgs,2);

resultIds = zeros(1,length(testLen));
correctLabel = 0;

fbgSRCNormalize = 0;

doCosine = 0;
try, doCosine = opt.algorithm.src.prune.doCosine; end

if ~doCosine && (~exist('Ainv', 'var'))% || (exist('clearLibsvm', 'var') && clearLibsvm == 0))
	kappa = 0;
    try, kappa = opt.algorithm.src.l2.regularization; end;
    if kappa == -1
        kappa = 0.001*length(fbgTrainImgs)/700;
    end
    if kappa > 0
        [u,s,v] = svd(fbgTrainImgs,'econ');
        d = diag(s);
        d = d ./ (d.^2 + kappa^2);
        Ainv = v*diag(d)*u';
    else
        Ainv = pinv(fbgTrainImgs);
	end
	%fprintf(' %f kappa ', kappa);
end

trunc = 0;
try, trunc = opt.algorithm.src.l2.truncateTo; end

allClasses = unique(fbgTrainIds);
numClassTrainImgs = zeros(length(allClasses),1);
minResiduals = zeros(testLen,1);

for i = 1 : length(allClasses)
    numClassTrainImgs(i) = sum(fbgTrainIds == allClasses(i));
end

classes = unique(fbgTrainIds);

classNorm = zeros(1,length(classes));
cacheId = {};
for j = 1 : length(classes)
    classNorm(j) = sum(fbgTrainIds == classes(j));
    cacheIdx{j} = find(fbgTrainIds == classes(j));
end
cacheIdxOcc = find(fbgTrainIds == -1);

fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
cdistMatrix = zeros(length(fbgTestIds)+1,length(classes)+2);

batch = 1;
try, batch = opt.algorithm.l2.batchSize; end
if ischar(batch), batch = str2double(batch); end;
topRes = 0;
try, topRes = opt.algorithm.src.prune.topRes; end
lsrcDown = 0;
try, lsrcDown = opt.algorithm.src.prune.lsrcDown; end
occAI = 0;
try, occAI = opt.algorithm.src.occAI; end;

if topRes > 0
    bestX = zeros(topRes,length(fbgTestIds));
    bestXP = zeros(topRes,length(fbgTestIds));
end

for m = [1:batch:testLen testLen]
	len = min([batch-1, testLen-m]);
	
	if length(fbgTestIds) == 0 || len < 0, break; end
	
    if doCosine
        xpBatch = fbgTrainImgs'*fbgTestImgs(:,m:m+len);
        if 1
            [mv,mi] = max(abs(xpBatch),[],1);
            lambdaMax = mv;
            bstar = fbgTrainImgs(:,mi);
            bb = fbgTrainImgs'*bstar;
            for k = 1:len
                bb(:,k) = (lambdaMax(k) - tau)*bb(:,k);
            end
            st3 = abs(xpBatch - bb);
            xpBatch = st3;
        else
            xpBatch = abs(xpBatch);
        end
    else
        xpBatch = Ainv * fbgTestImgs(:,m:m+len);
    end
	xp = xpBatch;
	residuals = zeros(len+1,length(classes));
        
	if trunc
        truncX = trunc;
        if trunc <= 1
            truncX = floor(trunc*length(fbgTrainIds));
        end
		for j = 1:size(xp,2)
			[sv,si] = sort(abs(xp(:,j)), 1, 'ascend');
			xp(si(1:(max(length(si) - truncX, 0))), j) = 0;
		end
	end
    
%    [sv,si] = sort(abs(xp),'ascend');
%    xp(500:end) = 0;

	% Compute the residuals per class
	k = length(classes);
	kval = zeros(k,len+1);
    if ~lsrcDown || strcmp(opt.algorithm.name, 'src_l2') || strcmp(opt.algorithm.name, 'pca_src_l2')
        sumxp = sum(abs(xp));
        for j = 1:length(classes)
            if ~exist('useCache', 'var') || useCache
                idx = cacheIdx{j};
            else
                idx = find(fbgTrainIds == classes(j));
			end

			if kappa ~= 0
				residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:)).^2,1)) ./ sqrt(sum(xp(idx,:)).^2);
            else
                if occAI
                    residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:) - fbgTrainImgs(:,cacheIdxOcc)*xp(cacheIdxOcc,:)).^2,1)); ;
                else
                    residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:)).^2,1));
                end
            end
            

            
            kval(j,:) = sum(abs(xp(idx,:))) ./ sumxp;
        end

        sci(m:m+len) = (k.*max(kval)-1)./(k-1);
    end
    
    if topRes > 0
        [sv,si] = sort(abs(xp), 1, 'descend');
        bestX(:,m:m+len) = si(1:topRes,:);
        bestXP(:,m:m+len) = sv(1:topRes,:);
    end

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