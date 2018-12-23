%train_scr;

% I have a feeling that all zeros messes with the minimization, so let's
% make it rand...this way it shouldn't match to anything
for i = 1 : size(fbgTrainImgs,2)
    n = norm(fbgTrainImgs(:,i));
    if n < eps
        fbgTrainImgs(:,i) = rand(size(fbgTrainImgs(:,i)));
        n = norm(fbgTrainImgs(:,i));
    end

    fbgTrainImgs(:,i) = fbgTrainImgs(:,i) ./ n;
end

classes = unique(fbgTrainIds);

classNorm = zeros(1,length(classes));
cacheIdx = {};
for j = 1 : length(classes)
    classNorm(j) = sum(fbgTrainIds == classes(j));
    cacheIdx{j} = find(fbgTrainIds == classes(j));
    cacheAinv{j} = pinv(fbgTrainImgs(:,cacheIdx{j}));
end