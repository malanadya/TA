% svmMin = min(fbgTrainImgs(:));
% svmMax = max(fbgTrainImgs(:));
% fbgTrainImgs = (fbgTrainImgs - svmMin) ./ (svmMax - svmMin)*2 - 1;

numIters = 1;

classes = unique(fbgTrainIds);
numClasses = length(classes);

eta0 = 5e-6;% 10^-2;
eta0 = 2e-6;% 10^-2;
c = 1;
lambda = 0.1;


if 0
    W = zeros(size(fbgTrainImgs,1), length(classes));
    B = zeros(length(classes),1);
    for k = 1:numClasses
        w = ones(size(fbgTrainImgs,1),1);
        b = 0;
        wa = ones(size(fbgTrainImgs,1),1);
        ba = 0;
        fprintf('Class %d/%d...', k, numClasses);

        p = mean(fbgTrainImgs(:,fbgTrainIds == classes(k)),2);
        n = mean(fbgTrainImgs(:,fbgTrainIds ~= classes(k)),2);


        w = (p-n); wa = w;
        b = -norm(p-n) / 1000; ba = b;
        %b = -norm(p-n) / 500; ba = b;
        %w = cross(p + (n - p) / 2, rand(size(p)));
        %b = 0;

        margin = fbgTrainIds;
        idx = randperm(size(fbgTrainImgs,2));
        for i = 1:size(fbgTrainImgs,2)
            x = fbgTrainImgs(:,idx(i));

            if fbgTrainIds(i) == classes(k);
                y = 1;
            else
                y = -1;
            end
            margin(i) = y*(w'*x+b); %\detla_t

            wOld = w;
            bOld = b;

            eta = eta0 * 1 / (1 + lambda*eta0*i)^c;

            if margin(i) < 1
                w = (1-lambda*eta)*w + eta*y*x;
                b = b + eta*y;
            else
                w = (1-lambda*eta)*w;
                %b = b;
            end

            alpha = 1/i;
            wa = (1-alpha)*w + alpha*wOld;
            ba = (1-alpha)*b + alpha*bOld;
        end

        W(:,k) = wa;
        B(k) = ba;


        % sanity checking
        Y = W(:,k)'*fbgTrainImgs+B(k);
        Ypred = Y > 0;
        Yreal = fbgTrainIds == classes(k);
        fprintf('%0.2f%% %0.2f%%\n', 100*sum(Ypred(:) == Yreal(:)) / length(Yreal), 100*sum((Ypred(:) & Yreal(:))) / sum(Yreal));
        continue;
    end
else
    W = single(zeros(size(fbgTrainImgs,1), length(classes)));
    B = single(zeros(length(classes),1));
    
    tic
    for k = 1:numClasses
        w = ones(size(fbgTrainImgs,1),1);
        b = 0;
        wa = ones(size(fbgTrainImgs,1),1);
        ba = 0;
        %fprintf('Class %d/%d...', k, numClasses);

        p = mean(fbgTrainImgs(:,fbgTrainIds == classes(k)),2);
        n = mean(fbgTrainImgs(:,fbgTrainIds ~= classes(k)),2);

        w = (p-n); wa = w;
        b = -norm(p-n) / 1000; ba = b;
        
        W(:,k) = wa;
        B(k) = ba;
    end
    toc
    
    tic, [W,B] = trainasgdsvm(fbgTrainImgs, W, B, fbgTrainIds, classes, eta0, c, lambda); toc
    
    for k = 1:numClasses
        % sanity checking
        Y = W(:,k)'*fbgTrainImgs+B(k);
        Ypred = Y > 0;
        Yreal = fbgTrainIds == classes(k);
        fprintf('%0.2f%% %0.2f%%\n', 100*sum(Ypred(:) == Yreal(:)) / length(Yreal), 100*sum((Ypred(:) & Yreal(:))) / sum(Yreal));
    end
end
return;

% %% do some sanity checking
% for k = 1:1%numClasses
%     Y = W(:,k)'*fbgTrainImgs+B(k);
%     Ypred = Y > 0;
%     Yreal = fbgTrainIds == classes(k);
%     fprintf('Class %d: %0.1f\n', k, sum(Ypred == Yreal) / length(Yreal));
% end

%c = 1;
%try, c = opt.algorithm.svm.slackC; end
%svmmodel = train_liblinear_dense(double(fbgTrainIds), double(fbgTrainImgs'), sprintf('-s 2 -c %f -q 1', c));