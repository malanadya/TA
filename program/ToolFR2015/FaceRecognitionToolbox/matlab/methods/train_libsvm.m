% Needed if not using a linear kernel
% fbgTrainImgs = fbgTrainImgs ./ 255;

svmMin = min(fbgTrainImgs(:));
svmMax = max(fbgTrainImgs(:));
fbgTrainImgs = (fbgTrainImgs - svmMin) ./ (svmMax - svmMin);

if ~exist('svmParamSearch')
	c = 0.01;
    svmTrainParams = sprintf('-b %d -t 0 -c %f -g 0.07 -m 2000', fbgProbabilisticSVMs, c);
end

libsvm(OPT_SET_DATA, fbgTrainIds, fbgTrainImgs, svmTrainParams);
% clear fbgTrainImgs;
libsvm(OPT_TRAIN);
%libsvm(OPT_SAVE, 'svm_model.dat');

%f = dir('svm_model.dat');
%fbgTrainMemSize = f(1).bytes;