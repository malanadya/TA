batch = 100;
totalAccuracy = 0;
totalImgs = 0;
maxBatch = length(fbgTestIds) / batch;

% Normalize
fbgTestImgs = (fbgTestImgs - svmMin) ./ (svmMax - svmMin)*2 - 1;
% Normalize the columns of A to have unit l^2-norm.
% for i = 1 : size(fbgTestImgs,2)
%     fbgTestImgs(:,i) = fbgTestImgs(:,i) / norm(fbgTestImgs(:,i));
% end

%[predict_label, accuracy, dec_values] = predict(double(fbgTestIds), sparse(double(fbgTestImgs')), svmmodel);
[predict_label, accuracy, dec_values] = predict_liblinear_dense(double(fbgTestIds), double(fbgTestImgs'), svmmodel);

fbgAccuracy = accuracy;

uids = unique(fbgTrainIds);

doProb = 0;
if doProb
	distMatrix = [];
	cdistMatrix = [];
	probMatrix = [];
	prob = 1 ./ (1 + exp(-dec_values));
	[mv,mi] = max(prob');
	distMatrix = [1-mv' predict_label fbgTestIds];
	cdistMatrix = [1-prob predict_label fbgTestIds; unique(fbgTrainIds)' 0 0;];
	custConf = mv ./ sum(prob');
else
% 	svmMin2 = min(dec_values(:));
% 	svmMax2 = max(dec_values(:));
% 	dec_values = (dec_values - svmMin2) ./ (svmMax2 - svmMin2);
	
	custConf = [];
	[mv,mi] = max(dec_values');
	distMatrix = [];
	cdistMatrix = [];
	probMatrix = [];
	distMatrix = [1-mv' predict_label fbgTestIds];
	cdistMatrix = [1-dec_values predict_label fbgTestIds; unique(fbgTrainIds)' 0 0;];
	%probMatrix = [probMatrix labelMatrix fbgTestIds];
	%custConf = mv ./ sum(dec_values)';
end