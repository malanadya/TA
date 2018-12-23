% Initialize storage for residual results
residuals = zeros(1,length(classes));

% Compute the residuals.
for j = 1 : length(classes)
    if ~exist('useCache', 'var') || useCache
        idx = cacheIdx{j};
        occIdx = cacheIdxOcc;
    else
        idx = find(fbgTrainIds == classes(j));
        occIdx = find(fbgTrainIds == -1);
    end
    
    if exist('occAI', 'var') && occAI
        residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs(:,idx) * xp(idx) - fbgTrainImgs(:,occIdx)*xp(occIdx));
    else
        residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs(:,idx) * xp(idx));
    end
        
%     if fbgSRCMethod == SRC_OCC
%         residuals(j) = norm(fbgTestImgs(:,i) - xp(idx2) - fbgTrainImgs(:,idx) * xp(idx));
%     else
%%%        residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs(:,idx) * xp(idx));
%     end
% Don't normalize by class
end

% Normalize by classes (bad idea)
if fbgSRCNormalize
    residuals = residuals ./ classNorm;
end

% Compute SCI
k = length(classes);
kval = zeros(k,1);
for j = 1:k
    if ~exist('useCache', 'var') || useCache
        idx = cacheIdx{j};
    else
        idx = find(fbgTrainIds == classes(j));
    end
    kval(j) = sum(abs(xp(idx))) / sum(abs(xp));
end
sci(i) = (k*max(kval)-1)/(k-1);