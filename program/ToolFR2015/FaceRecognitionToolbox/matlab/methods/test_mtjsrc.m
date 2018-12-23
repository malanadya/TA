fbgTrainImg = single(fbgTrainImgs);
fbgTestImgs = single(fbgTestImgs);

testLen = size(fbgTestImgs,2);
numFeats = length(fbgFeatureLengths);

% eta = 0.002
% lambd = 0.001
opt_mtjsrc.eta = 0.002;
opt_mtjsrc.lambda = 0.001;
opt_mtjsrc.ite_num = 5;
try, opt_mtjsrc.ite_num = opt.algorithm.mtjsrc.iterations; end

if mtjsrcUseKernel
    opt_mtjsrc.kernel_view = 1;
else
    opt_mtjsrc.kernel_view = 0;
end

classes = unique(fbgTrainIds);
minResiduals = zeros(testLen,1);
resultIds = zeros(testLen,1);
correctLabel = 0;
fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
for i = 1 : testLen
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, length(fbgTestIds));
    Y_task = cell(numFeats,1);
    for f = 1 : numFeats
        if f == 1
            endFeatLen = fbgFeatureLengths(f);
            
            if mtjsrcUseKernel
                tempFeat = fbgTestImgs(1:endFeatLen,i);
                tempFeat = tempFeat ./ norm(tempFeat);
                tempFeat = sqrt(distSqr(fbgTrainImgs(1:endFeatLen,:), tempFeat));
                Y_task{f} = exp(-fbgTrainMu{f} * tempFeat);
%                 Y_task{f} = slmetric_pw(fbgTrainImgs(1:endFeatLen,:), fbgTestImgs(1:endFeatLen,i), 'chisq');
            else
                %Y_task{f} = fbgTrainImgs(1:endFeatLen,i) ./ norm(fbgTrainImgs(1:endFeatLen,i));
                Y_task{f} = fbgTestImgs(1:endFeatLen,i) ./ norm(fbgTestImgs(1:endFeatLen,i) + eps);
            end
        else
            begFeatLen = endFeatLen + 1;
            endFeatLen = endFeatLen + fbgFeatureLengths(f);
            if mtjsrcUseKernel
                tempFeat = fbgTestImgs(begFeatLen:endFeatLen,i);
                tempFeat = tempFeat ./ norm(tempFeat);
                tempFeat = sqrt(distSqr(fbgTrainImgs(begFeatLen:endFeatLen,:),tempFeat) + eps);
                Y_task{f} = exp(-fbgTrainMu{f} * tempFeat);
%                 Y_task{f} = slmetric_pw(fbgTrainImgs(begFeatLen:endFeatLen,:), fbgTestImgs(begFeatLen:endFeatLen,i), 'chisq');
            else
                % Y_task{f} = fbgTrainImgs(begFeatLen:endFeatLen,i);
                Y_task{f} = fbgTestImgs(begFeatLen:endFeatLen,i) ./ norm(fbgTestImgs(begFeatLen:endFeatLen,i));
            end
        end
    end
       
    W = MTJSRC_APG(X_task, Y_task, Q, group_index_task, opt_mtjsrc);

    [predClass,val,residuals] = Classify(Y_task, X_task, group_index_task, weight_task, W, opt_mtjsrc);
    
    minResiduals(i) = val;
    resultIds(i) = predClass;
end

correctLabel = sum(resultIds == fbgTestIds);

distMatrix = [minResiduals resultIds fbgTestIds];

% Need to add dist matrices.
fbgAccuracy = 0;
if testLen
  fbgAccuracy = 100 * correctLabel / testLen;
end