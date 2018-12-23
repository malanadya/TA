%fbgTestImgs = (fbgTestImgs - svmMin) ./ (svmMax - svmMin)*2-1;

% Try to model and calibrate each svm
D = W'*fbgTrainImgs;
for i = 1:size(fbgTrainImgs,1)
    D(:,i) = D(:,i) + B; 
end

% Let's try simple z-score
M = zeros(numClasses,1);
S = zeros(numClasses,1);
for i = 1:numClasses
    M(i) = mean(D(i,:));
    S(i) = std(D(i,:));
end

% Dz = D;
% for i = 1:numClasses
%     Dz(i,:) = (Dz(i,:) - M(i)) ./ S(i); 
% end
% 
% [sv,si] = sort(Dz, 'descend');
% fbgResultIds = classes(si(1,:));
% fbgAccuracy = 100*sum(fbgResultIds == fbgTrainIds) / length(fbgTrainIds)
% 
% return;

D = W'*fbgTestImgs;

Bb = B;
% Bb(1) = -10000;
% Bb(end) = -10000;

% Add bias
for i = 1:size(fbgTestImgs,1)
    D(:,i) = D(:,i) + Bb; 
end

if 0
    [sv,si] = sort(D, 'descend');
else
    Dz = D;
    for i = 1:numClasses
        Dz(i,:) = (Dz(i,:) - M(i)) ./ S(i); 
    end
    [sv,si] = sort(Dz, 'descend');
end

fbgResultIds = classes(si(1,:));
fbgAccuracy = 100*sum(fbgResultIds == fbgTestIds) / length(fbgTestIds)

custConf = [];
mv = sv(1,:);
distMatrix = [];
cdistMatrix = [];
probMatrix = [];
distMatrix = [1-mv' fbgResultIds fbgTestIds];
cdistMatrix = [1-D' fbgResultIds fbgTestIds; unique(fbgTrainIds)' 0 0;];


return;

for k = 1:1%numClasses
    Y = W(:,k)'*fbgTestImgs+B(k);
    Ypred = Y > 0;
    Yreal = fbgTrainIds == classes(k);
    fprintf('Class %d: %0.1f\n', k, sum(Ypred == Yreal) / length(Yreal));
end







batch = 100;
totalAccuracy = 0;
totalImgs = 0;
maxBatch = length(fbgTestIds) / batch;

% Normalize
fbgTestImgs = (fbgTestImgs - svmMin) ./ (svmMax - svmMin);
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

%%
D = svmmodel.w*fbgTestImgs;

if 1
    [sv,si] = sort(D, 'descend');
else
    Dz = D;
    for i = 1:numClasses
        Dz(i,:) = (Dz(i,:) - M(i)) ./ S(i); 
    end
    [sv,si] = sort(Dz, 'descend');
end
fbgResultIds = svmmodel.Label(si(1,:));
fbgAccuracy = 100*sum(fbgResultIds == fbgTestIds) / length(fbgTestIds)