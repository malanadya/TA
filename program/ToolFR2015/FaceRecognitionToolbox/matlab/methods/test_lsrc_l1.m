%test_src_l2; % Run L2 first, then we'll refine the results

% %%% HACKE!!
% if length(fbgTestIds) ~= 011720
%     distMatrix = [];
%     custConf = [];
%     cdistMatrix = [];
%     return;
% end

skipNorm = 0;
try, skipNorm = opt.algorithm.src.skipPreNorm; end

if lasrcfast >= 1
    fprintf('%d %d\n', size(fbgTestImgs));
    fbgTestImgsWhole = fbgTestImgs;
    %fbgTrainImgs = [];
    %for i = 1:length(lasrcdims)
        %fbgTrainImgs = [fbgTrainImgs fbgTrainImgsWhole((i-1)*lasrcdims(1)+1
    if lasrcfast == 2
         fbgTestImgs = [fbgTestImgs(1:256,:); fbgTestImgs(512+1:512+256,:); fbgTestImgs(512*2+1:512*2+256,:)];
    elseif lasrcfast == 3
        fbgTestImgs = [fbgTestImgs(1:192,:); fbgTestImgs(512+1:512+192,:); fbgTestImgs(512*2+1:512*2+192,:)];
    elseif lasrcfast == 5
        fbgTestImgs = [fbgTestImgs(1:170,:); fbgTestImgs(512+1:512+170,:); fbgTestImgs(512*2+1:512*2+170,:)];
    end
    %end
end

algo = 'src_l2';
try, algo = opt.algorithm.src.prune.algorithm; end;
eval(sprintf('test_%s', algo));

if lasrcfast >= 1
    fbgTrainImgs = fbgTrainImgsWhole;
    fbgTestImgs = fbgTestImgsWhole;
end

SRC_L1LS = 0;
SRC_GPSR = 2;
SRC_YALL1 = 1;
SRC_OCC = 5;
SRC_GPSRFAST = 7;
SRC_HOMO = 8;
SRC_DALM = 9;
SRC_GPSRFAST_OCC = 10;
SRC_GPSRFAST_OCCe = 11;
SRC_RWL2 = 12;
SRC_OMP = 13;
SRC_BACKSLASH = 14;
SRC_LLC = 15;
SRC_SVM = 16;
SRC_L1LS_REAL = 17;
SRC_USE_L2 = 18;
SRC_FAST_L2 = 19;

fbgSRCNormalize = 0;

% Let caller scripts specify the tau and SRC method
try, tau = eval(opt.algorithm.src.tau); end
fbgSRCMethod = SRC_GPSRFAST;
try, fbgSRCMethod = eval(opt.algorithm.src.method); end
topRes = 20;
try, topRes = opt.algorithm.src.prune.topRes; end
perRem = 0.3;
try, perRem = opt.algorithm.src.prune.downSamp; end

% This just makes it easy so we can swap between algorithms
% if fbgSRCMethod == SRC_RWL2
% 	disp('RWL2 NOT IMPLEMENTED FOR L2+L1');
% 	test_src_rwl2;
% 	return;
% end

% Normalize the columns of A to have unit l^2-norm.
if clip > 0
    fbgTestImgs(fbgTestImgs > clip) = clip;
    fbgTestImgs(fbgTestImgs < clip) = -clip;
end
if ~skipNorm
    for i = 1 : size(fbgTestImgs,2)
        fbgTestImgs(:,i) = fbgTestImgs(:,i) / (norm(fbgTestImgs(:,i))+eps);
    end
end

% fbgTrainImgs = single(fbgTrainImgs);
% fbgTestImgs = single(fbgTestImgs);

testLen = size(fbgTestImgs,2);

if fbgSRCMethod == SRC_YALL1
    [Q, R] = qr(fbgTrainImgs',0);
    fbgTrainImgs = Q';% b = R'\b;
elseif fbgSRCMethod == SRC_L1LS
    if ~exist('Ainv', 'var')
        Ainv = pinv(fbgTrainImgs);
    end
elseif fbgSRCMethod == SRC_OCC
    fbgTrainImgs = [fbgTrainImgs, eye(length(fbgTrainImgs(:,1)))];
    idx2 = find([zeros(length(fbgTrainIds),1); ones(length(fbgTrainImgs(:,1)),1)]);
end

allClasses = unique(fbgTrainIds);
numClassTrainImgs = zeros(length(allClasses),1);
minResiduals = zeros(testLen,1);

% Make sure we aren't trying to keep too many identities
%topRes = min(topRes, length(classes));

for i = 1 : length(allClasses)
    numClassTrainImgs(i) = sum(fbgTrainIds == allClasses(i));
end

classes = unique(fbgTrainIds);
if classes(1) == -1
    classes(1) = [];
end

classNorm = zeros(1,length(classes));
cacheIdx = {};
for j = 1 : length(classes)
    classNorm(j) = sum(fbgTrainIds == classes(j));
    cacheIdx{j} = find(fbgTrainIds == classes(j));
end
cacheIdxOcc = find(fbgTrainIds == -1);

occAI = 0; try, occAI = opt.algorithm.src.occAI; end

rclasses = zeros(max(classes),1);
for j = 1:length(classes)
	rclasses(classes(j)+1) = j;
end


%%% Temp
%load('\\192.168.2.10\cviu_datasets\lfwpubfig5\mat\t_lfwpubfig_0200_0000af22_pca_512justcat1_gaborhoglbp5_v3__distract_sA.mat');
%load('F:\cviu_datasets\libsvmtests\sA_mean_1024_0.mat');

% LSRC
A = fbgTrainImgs;
Aids = fbgTrainIds;
Aclasses = classes;
% END LSRC

%%

resultIds = zeros(1,testLen);
correctLabel = 0;

%BCB: cdistMatrix already created by the pruning algorithm
%cdistMatrix = zeros(length(fbgTestIds)+1,length(classes)+2);
sci = zeros(length(fbgTestIds),1);

otherIdx = zeros(topRes, length(fbgTestIds));
otherRes = zeros(topRes, length(fbgTestIds));

if fbgSRCMethod == SRC_GPSRFAST
    fbgSRCMethod = SRC_GPSR;
end

if fbgSRCMethod == SRC_GPSRFAST
    disp('SRC_GPSRFAST NOT IMPLEMENTED FOR L2+L1');
    fbgSRCMethod == SRC_GPSR;
elseif fbgSRCMethod == SRC_GPSRFAST_OCC || fbgSRCMethod == SRC_GPSRFAST_OCCe
    disp('SRC_GPSRFAST NOT IMPLEMENTED FOR L2+L1');
else
	numGPSRImgs = [];
	sortedIds = [];
	fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
    iter = [];
	for i = 1:testLen
		fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, length(fbgTestIds));
        
        
        % START IMAGE GLOBAL DOWNSAMPLING
        keepIdx = bestX(:,i);
        fbgTrainIds = Aids(keepIdx);
        fbgTrainImgs = A(:,keepIdx);
        tst = fbgTestImgs(:,i);
        % END IMAGE DOWNSAMPLING

%         % norm now if we didn't do it before hand
%         if ~skipNorm
%             tst = tst ./ (norm(tst) + eps);
%             for k = 1:size(fbgTrainImgs,2)
%                 fbgTrainImgs(:,k) = fbgTrainImgs(:,k) ./ (norm(fbgTrainImgs(:,k)) + eps);
%             end
%         end
        
        if fbgSRCMethod == SRC_USE_L2
            xp = bestXP(:,i);
        elseif fbgSRCMethod == SRC_GPSR || fbgSRCMethod == SRC_OCC
			%[xp,iter(end+1)] = GPSR_BB(tst,fbgTrainImgs,tau,'Verbose',0,'MaxiterA',10);
            [xp,iter(end+1)] = GPSR_BB(tst,fbgTrainImgs,tau,'Verbose',0);
            %tic, [xpi,iter(end+1)] = GPSR_BB(tst,fbgTrainImgs,tau,'Verbose',0,'Initialization',bestXP(:,i)); b = toc;
            %fprintf('\n%f %f  %f\n', a, b, norm(xp - xpi));
		elseif fbgSRCMethod == SRC_YALL1
			opts.tol = 5e-8;
			opts.print = 0;
			[xp,Out] = yall1(fbgTrainImgs, R'\tst, opts); 
		elseif fbgSRCMethod == SRC_L1LS
			x0 = Ainv(keepIdx,:) * tst;
%			epsilon = 0.05;
	% 		xp = l1qc_logbarrier(x0, fbgTrainImgs, [], tst, epsilon, 1e-3);
%			xp = l1eq_pd(x0, fbgTrainImgs, [], tst, epsilon);
            epsilon = tau;
            xp = l1qc_logbarrier(x0, fbgTrainImgs, [], tst, epsilon, 1e-3);
            %xp = l1eq_pd(x0, fbgTrainImgs, [], tst, epsilon);
        elseif fbgSRCMethod == SRC_L1LS_REAL
            xp = l1_ls(fbgTrainImgs, tst, tau, 1e-3, 1);
		elseif fbgSRCMethod == SRC_HOMO
			[xp,iter(end+1)] = solvehomotopy(fbgTrainImgs, tst, 'lambda', tau, 'tolerance', 1e-6, 'isnonnegative', false);
        elseif fbgSRCMethod == SRC_DALM
            [xp,iter] = SolveDALM_fast(fbgTrainImgs, tst, 'lambda', tau);
		elseif fbgSRCMethod == SRC_BACKSLASH;
			xp = (tst \ fbgTrainImgs)';
        elseif fbgSRCMethod == SRC_LLC
            xp = LLC_coding_appr(fbgTrainImgs', tst', size(fbgTrainImgs,2), 1e-4)';
        elseif fbgSRCMethod == SRC_RWL2
            numIter = 10;
            reltol = 1e-2;
            stopCrit = 3;
            spCoef = 64;
            At = fbgTrainImgs';    
            xp = SolveIRWLS(fbgTrainImgs, tst, 'aprime', At, 'lambda', tau, 'tolerance', reltol, 'maxiteration', numIter, 'stoppingcriterion', stopCrit, 'sparsity', spCoef, 'isnonnegative', false);
        elseif fbgSRCMethod == SRC_FAST_L2
            classes = unique(fbgTrainIds);
            resId = classes;
            
            xp = bestXP(:,i);
            
            prob = zeros(size(classes));
            allSum = sum(abs(xp));
            for kk = 1:length(classes)
                prob = sum(abs(xp(fbgTrainIds == classes(kk))));
            end
            prob = prob ./ allSum;
            
            classes = Aclasses;
            
            % All classes that weren't in the top picks should be residual 1.0
            cdistMatrix(i,1:length(classes)) = 1.0; 
            % Store top picks in their corresponding places
            cdistMatrix(i,rclasses(resId+1)) = 1-prob;
            % Retreive the full residuals so our accuracy check is correct
            residuals = cdistMatrix(i,1:length(classes));

            % Minimum residual error indicates to which class the object (face)
            % belongs.
            [val, ind] = min(residuals);
            minResiduals(i) = val;
            resultIds(i) = classes(ind);
            
            k = length(classes);
            sci(i) = (k*max(prob)-1)/(k-1);
            
            %assert(resultIds(i) == predict_label_P);
            
            if resultIds(i) == fbgTestIds(i)
            %if predict_label_P == fbgTestIds(i)
                correctLabel = correctLabel + 1;
            end
            
            continue;
        elseif fbgSRCMethod == SRC_SVM
            
            classes = unique(fbgTrainIds);
            resId = classes;
            
            if length(classes) > 1
                tstids = fbgTestIds(i);
                tst = tst;
                
                % It is important to re-order the training samples so 
                %trn = fbgTrainImgs;
                %trnids = fbgTrainIds;
                trn = [];
                trnids = [];
                for kk = 1:length(classes)
                    mask = fbgTrainIds == classes(kk);
                    trn = [trn fbgTrainImgs(:,mask)];
                    trnids = [trnids; fbgTrainIds(mask)];
                end
                trnids = trnids;
                
                doProb = 0;
                try, doProb = opt.algorithm.src.prune.svmProb; end;
                doOneVsAll = 0;
                try, doOneVsAll = opt.algorithm.src.prune.svmOneVsAll; end
                
                if 1
%                     svmMin = min(trn(:));
%                     svmMax = max(trn(:));
%                     trn = (trn - svmMin) ./ (svmMax - svmMin)*2-1;
%                     tst = (tst - svmMin) ./ (svmMax - svmMin)*2-1;
                    me = mean(trn,2);
                    for kk = 1:size(trn,2)
                        trn(:,kk) = trn(:,kk) - me;
                    end
                    ma = max(abs(trn(:)));
                    trn = trn ./ ma;
                    tst = (tst - me) ./ ma;

                    linTrain = double(trn'*trn);
                    linTest = double(tst'*trn);
%                     gamma = 1/size(trn,1);
%                     coef0 = 0;
%                     linTrain = double(tanh(gamma*trn'*trn+coef0));
%                     linTest = double(tanh(gamma*tst'*trn+coef0));

                    if doProb
                        if doOneVsAll
                            svmModel = ovrtrain(trnids, [(1:length(trnids))', linTrain], '-t 4 -q -b 1');
                            [predict_label_P, accuracy_P, prob] = ovrpredict(tstids, [(1:length(tstids))', linTest], svmModel, '-b 1');
                        else
                            svmModel = svmtrain31(trnids, [(1:length(trnids))', linTrain], '-t 4 -q -b 1');
                            [predict_label_P, accuracy_P, prob] = svmpredict31_noprint(tstids, [(1:length(tstids))', linTest], svmModel, '-b 1');
                        end
                    else
                        if doOneVsAll
                            svmModel = ovrtrain(trnids, [(1:length(trnids))', linTrain], '-t 4 -q');
                            [predict_label_P, accuracy_P, prob] = ovrpredict(tstids, [(1:length(tstids))', linTest], svmModel);
                        else
                            svmModel = svmtrain31(trnids, [(1:length(trnids))', linTrain], '-t 4 -q');
                            [predict_label_P, accuracy_P, prob] = svmpredict31_noprint(tstids, [(1:length(tstids))', linTest], svmModel);
                            % Kinda lame probability vote. Taken in part from libsvm
                            % file svm.cpp function svm_predict_values line 2479
                            % Seems like it might work better than -b 1 in libsvm
                            % because we have so few samples
                            p = 1;
                            votes = zeros(size(classes));
                            for m = 1:length(classes)
                                for n = m+1:length(classes)
                                    a = abs(prob(p));
                                    if prob(p) > 0
                                        votes(m) = votes(m) + 10 + a;
                                    else
                                        votes(n) = votes(n) + 10 + a;
                                    end
                                    p = p + 1;
                                end
                            end
                            prob = votes ./ sum(abs(votes));% ./ (length(classes) - 1);
                        end
                    end
                else
                    trn = (trn - svmMin) ./ (svmMax - svmMin)*2-1;
                    tst = (tst - svmMin) ./ (svmMax - svmMin)*2-1;
                    pkTrain = ossScore(trn, trn, sA);
                    pkTest = ossScore(tst, trn, sA);
                    off = 2;
                    svmModel = svmtrain31(trnids, [(1:length(trnids))', exp((pkTrain+off))], sprintf('-t 4 -q -b %d', doProb));
                    [predict_label_P, accuracy_P, prob] = svmpredict31_noprint(tstids, [(1:length(tstids))', exp((pkTest+off))], svmModel, sprintf('-b %d', doProb));
                    if ~doProb
                        p = 1;
                        votes = zeros(size(classes));
                        for m = 1:length(classes)
                            for n = m+1:length(classes)
                                a = abs(prob(p));
                                if prob(p) > 0
                                    votes(m) = votes(m) + 10 + a;
                                else
                                    votes(n) = votes(n) + 10 + a;
                                end
                                p = p + 1;
                            end
                        end
                        prob = votes ./ sum(abs(votes));% ./ (length(classes) - 1);
                    end
                end
            else
                predict_label_P = classes;
                prob = 1;
            end
            
            classes = Aclasses;
            
            % All classes that weren't in the top picks should be residual 1.0
            cdistMatrix(i,1:length(classes)) = 1.0; 
            % Store top picks in their corresponding places
            cdistMatrix(i,rclasses(resId+1)) = 1-prob;
            % Retreive the full residuals so our accuracy check is correct
            residuals = cdistMatrix(i,1:length(classes));

            % Minimum residual error indicates to which class the object (face)
            % belongs.
            [val, ind] = min(residuals);
            minResiduals(i) = val;
            resultIds(i) = classes(ind);
            
            %assert(resultIds(i) == predict_label_P);
            
            if resultIds(i) == fbgTestIds(i)
            %if predict_label_P == fbgTestIds(i)
                correctLabel = correctLabel + 1;
            end
            
            continue;
		end
		
		otherIdx(:,i) = keepIdx;
		otherRes(:,i) = xp;

        useCache = false;
		classes = unique(fbgTrainIds);
        if classes(1) == -1
            classes(1) = [];
        end
        resId = classes;
		computeSrcResiduals;
		classes = Aclasses;

		% All classes that weren't in the top picks should be residual 1.0
		cdistMatrix(i,1:length(classes)) = 1.0; 
		% Store top picks in their corresponding places
		cdistMatrix(i,rclasses(resId+1)) = residuals;
		% Retreive the full residuals so our accuracy check is correct
		residuals = cdistMatrix(i,1:length(classes));

		% Minimum residual error indicates to which class the object (face)
		% belongs.
		[val, ind] = min(residuals);
		minResiduals(i) = val;
		resultIds(i) = classes(ind);

		if resultIds(i) == fbgTestIds(i)
			correctLabel = correctLabel + 1;
		end
	end
end

%try, fprintf(' %0.1f %0.1f %0.1f %0.1f\n', mean(iter), median(iter), min(iter), max(iter)); end

if fbgSRCMethod == SRC_OCC
    fbgTrainImgs = fbgTrainImgs(:,1:end-length(fbgTrainImgs(:,1)));
end

distMatrix = [minResiduals resultIds' fbgTestIds];
cdistMatrix(1:end-1,end-1) = resultIds';
cdistMatrix(1:end-1,end) = fbgTestIds;
cdistMatrix(end,1:length(classes)) = classes;

if fbgSRCMethod ~= SRC_LLC
    custConf = sci; % SRC_LLC doesn't use SCI because it's a least squares method
end

fbgTrainImgs = A;
fbgTrainIds = Aids;
clear A Aids useCache;

fbgAccuracy = 0;
if testLen
  fbgAccuracy = 100 * correctLabel / testLen;
end

extraInfo{end+1} = struct('otherIdx', otherIdx, 'otherRes', otherRes, 'fbgTrainIds', fbgTrainIds, 'iter', iter, 'sci', sci);