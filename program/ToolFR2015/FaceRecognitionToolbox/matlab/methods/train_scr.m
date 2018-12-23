% Normalize the columns of A to have unit l^2-norm.
% for i = 1 : size(fbgTrainImgs,2)
%     fbgTrainImgs(:,i) = fbgTrainImgs(:,i) / (norm(fbgTrainImgs(:,i))+eps);
% end

% don't do this!
clip = 0;
if clip > 0
    fbgTrainImgs(fbgTrainImgs > clip) = clip;
    fbgTrainImgs(fbgTrainImgs < clip) = -clip;
end

skipNorm = 0;
try, skipNorm = opt.algorithm.src.skipPreNorm; end

% I have a feeling that all zeros messes with the minimization, so let's
% make it rand...this way it shouldn't match to anything
if ~skipNorm
    for i = 1 : size(fbgTrainImgs,2)
        n = norm(fbgTrainImgs(:,i));
        if n < eps
            fbgTrainImgs(:,i) = rand(size(fbgTrainImgs(:,i)));
            n = norm(fbgTrainImgs(:,i));
        end

        fbgTrainImgs(:,i) = fbgTrainImgs(:,i) ./ n;
    end
end

try
    if opt.algorithm.src.occAI
        fbgTrainImgs = [fbgTrainImgs eye(size(fbgTrainImgs,1))];
        fbgTrainIds = [fbgTrainIds; -ones(size(fbgTrainImgs,1),1)];
    end
end