batch = 100;
totalAccuracy = 0;
totalImgs = 0;
maxBatch = length(fbgTestIds) / batch;

% Normalize
fbgTestImgs = (fbgTestImgs - svmMin) ./ (svmMax - svmMin);

if ~exist('svmParamSearch')
    fbgTestImgs = fbgTestImgs';
    svmTestParams = sprintf('-b %d', fbgProbabilisticSVMs);
end

probMatrix = [];
labelMatrix = [];
idMatrix = [];
for i = 1:maxBatch+1
	if i < maxBatch
		batchImgs = fbgTestImgs((i-1)*batch+1:i*batch, :);
		batchIds = fbgTestIds((i-1)*batch+1:i*batch);
	else
		batchImgs = fbgTestImgs((i-1)*batch+1:end,:);
		batchIds = fbgTestIds((i-1)*batch+1:end);
	end
	[predict_label, accuracy, prob] = libsvm(OPT_PREDICT, batchIds, batchImgs, svmTestParams);
	if fbgProbabilisticSVMs
		probMatrix = [probMatrix; prob];
		labelMatrix = [labelMatrix; predict_label];
	end
	numImgs = length(batchIds);
	totalAccuracy = totalAccuracy + accuracy(1) * numImgs;
	totalImgs = totalImgs + numImgs;
end

fbgAccuracy = totalAccuracy / totalImgs;
if ~exist('clearLibsvm', 'var') || clearLibsvm == 1
	libsvm(OPT_CLEAR);
end

distMatrix = [1-max(probMatrix,[],2) labelMatrix fbgTestIds];
cdistMatrix = [1-probMatrix labelMatrix fbgTestIds; unique(fbgTrainIds)' 0 0;];
probMatrix = [probMatrix labelMatrix fbgTestIds];
