mtjsrcUseKernel = false; 

if ~exist('fbgFeatureLengths', 'var') || isempty(fbgFeatureLengths)
    fbgFeatureLengths = [512 512 512];
end
try, fbgFeatureLengths = opt.algorithm.mtjsrc.featLens; end

numFeats = length(fbgFeatureLengths);
X_task = cell(numFeats,1);
group_index_task = cell(numFeats,1);
weight_task = cell(numFeats,1);
Q = cell(numFeats,1);
fbgTrainMu = cell(numFeats,1);
weight_prior = ones(1,numFeats);

opt_mtjsrc = [];
opt_mtjsrc.R = cell(numFeats,1);

for featNum =  1 : numFeats
    
    if featNum == 1
        endFeatLen = fbgFeatureLengths(featNum);
        tempFeats = fbgTrainImgs(1:endFeatLen,:);
    else
        beginFeatLen = endFeatLen + 1;
        endFeatLen = endFeatLen + fbgFeatureLengths(featNum);
        tempFeats = fbgTrainImgs(beginFeatLen:endFeatLen,:);
    end
    
    for j = 1:size(tempFeats,2)
        tempFeats(:,j) = tempFeats(:,j) ./ norm(tempFeats(:,j)+eps);
    end
    
    for i = 1 : size(tempFeats,2)
        tempFeats(:,i) = tempFeats(:,i) ./ norm(tempFeats(:,i));
    end

    if mtjsrcUseKernel
        
        tempFeats = sqrt(distSqr(tempFeats, tempFeats));
%         tempFeats = slmetric_pw(tempFeats, tempFeats, 'chisq');
        fbgTrainMu{featNum} = 1 / mean(mean(tempFeats));
        tempFeats = exp(-fbgTrainMu{featNum} * tempFeats);


%         Q{featNum} = inv(0.01 * eye(size(tempFeats,2)) + tempFeats);
        Q{featNum} = pinv(tempFeats);
    else
        % Q{k}stores the inverse of matrices (X{k}'X{k}+\beta I) fot task k
%         Q{featNum} = inv(0.1 * eye(size(tempFeats,2)) + tempFeats' * tempFeats) * tempFeats';
        Q{featNum} = pinv(tempFeats);
        opt_mtjsrc.R{featNum} = [];%tempFeats' * tempFeats;
    end
    
    X_task{featNum} = tempFeats;
    
    group_index_task{featNum} = length(unique(fbgTrainIds));
    group_index_task{featNum} = fbgTrainIds;
    weight_task{featNum} = weight_prior(1,featNum) ./ numFeats;
end