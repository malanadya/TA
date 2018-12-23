%addpath('liblinear');
svmMin = min(fbgTrainImgs(:));
svmMax = max(fbgTrainImgs(:));
fbgTrainImgs = (fbgTrainImgs - svmMin) ./ (svmMax - svmMin)*2 - 1;
% Normalize the columns of A to have unit l^2-norm.
% for i = 1 : size(fbgTrainImgs,2)
%     fbgTrainImgs(:,i) = fbgTrainImgs(:,i) / norm(fbgTrainImgs(:,i));
% end
%svmmodel = train(double(fbgTrainIds), sparse(fbgTrainImgs'), '-c 1 -s 2 -q 1');
%svmmodel = train(double(fbgTrainIds), sparse(double(fbgTrainImgs')), '-s 2 -c 1 -q 1');

c = 1;
try, c = opt.algorithm.svm.slackC; end

svmmodel = train_liblinear_dense(double(fbgTrainIds), double(fbgTrainImgs'), sprintf('-s 2 -c %f -q 1', c));