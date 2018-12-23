tau = 0.01; % Best >128 friends accuracy
tau = 0.000001;
tau = 0.1; % Best overall accuracy
tau = 0.25; % Best PR curve
tau = 0.4;
tau = 0.175;
tau = 0.001; % TAKES FOREVER!
tau = 0.3;
tau = 0.22;

tau = 0.1;
tau = 0.01;

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
SRC_RSC = 16;
SRC_L1LS_REAL = 17;
SRC_USE_L2 = 18;
SRC_FAST_L2 = 19;
SRC_OMP_BATCH = 25;

fbgSRCNormalize = 0;

% Let caller scripts specify the tau and SRC method
try, tau = eval(opt.algorithm.src.tau); end
fbgSRCMethod = SRC_GPSRFAST;
try, fbgSRCMethod = eval(opt.algorithm.src.method); end
reltol = 1e-6;
try, reltol = eval(opt.algorithm.src.tol); end
numIter = 100;
try, numIter = eval(opt.algorithm.src.numIter); end

% Pruning
prune = 0;
try, prune = opt.algorithm.src.prune.enable; end
downSamp = 0;
try, downSamp = opt.algorithm.src.prune.downSamp; end
oneshotPrune = 0;
try, oneshotPrune = opt.algorithm.src.prune.oneshot; end
lsrcDown = 0;
try, lsrcDown = opt.algorithm.src.prune.lsrcDown; end
batch = 1;
try, batch = opt.algorithm.l1.batchSize; end
topRes = 64;
try, topRes = opt.algorithm.src.prune.topRes; end

if prune && lsrcDown
    test_lsrc_l1;
    return;
end

% Normalize the columns of A to have unit l^2-norm.
for i = 1 : size(fbgTestImgs,2)
    fbgTestImgs(:,i) = fbgTestImgs(:,i) / (norm(fbgTestImgs(:,i))+eps);
end

fbgTrainImgs = single(fbgTrainImgs);
fbgTestImgs = single(fbgTestImgs);

testLen = size(fbgTestImgs,2);

resultIds = zeros(1,length(testLen));
correctLabel = 0;


if fbgSRCMethod == SRC_YALL1
    [Q, R] = qr(fbgTrainImgs',0);
    fbgTrainImgs = Q';% b = R'\b;
elseif fbgSRCMethod == SRC_L1LS
    Ainv = pinv(fbgTrainImgs);
elseif fbgSRCMethod == SRC_OCC
    fbgTrainImgs = [fbgTrainImgs, eye(length(fbgTrainImgs(:,1)))];
    idx2 = find([zeros(length(fbgTrainIds),1); ones(length(fbgTrainImgs(:,1)),1)]);
end

allClasses = unique(fbgTrainIds);
numClassTrainImgs = zeros(length(allClasses),1);
minResiduals = zeros(testLen,1);

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

cdistMatrix = zeros(length(fbgTestIds)+1,length(classes)+2);
sci = zeros(length(fbgTestIds),1);
if fbgSRCMethod == SRC_GPSRFAST
	fprintf(' Test:');
    if batch == 1
        blocksize = floor(length(fbgTestIds)/5);
        blocksize = max([min([blocksize 512]) 2]);
    %  	blocksize = floor(length(fbgTestIds)/20);
    %  	blocksize = max([min([blocksize 128]) 4]);
        blocksize = 64;
        [X,totIter] = GPSR_BCBm(fbgTestImgs,fbgTrainImgs,tau,blocksize);
        fprintf(' ');

        for i = 1:testLen
            xp = full(X(:,i));

            computeSrcResiduals;

            cdistMatrix(i,1:length(classes)) = residuals;

            % Minimum residual error indicates to which class the object (face)
            % belongs.
            [val, ind] = min(residuals);
            minResiduals(i) = val;
            resultIds(i) = classes(ind);

            if resultIds(i) == fbgTestIds(i)
                correctLabel = correctLabel + 1;
            end
        end
    else
        
        fprintf(' %0.6d/%0.6d', 0, length(fbgTestIds));
        for m = [1:batch:testLen testLen]
            len = min([batch-1, testLen-m]);

            if length(fbgTestIds) == 0 || len < 0, break; end

            [xp,totIter] = GPSR_BCBm(fbgTestImgs(:,m:m+len),fbgTrainImgs,tau,len+1, 0);
            xp = full(xp);
            residuals = zeros(len+1,length(classes));

            k = length(classes);
            kval = zeros(k,len+1);
            sumxp = sum(abs(xp));
            for j = 1:length(classes)
                if ~exist('useCache', 'var') || useCache
                    idx = cacheIdx{j};
                else
                    idx = find(fbgTrainIds == classes(j));
                end

                if occAI
                    residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:) - fbgTrainImgs(:,cacheIdxOcc)*xp(cacheIdxOcc,:)).^2,1)); ;
                else
                    %residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:)).^2,1));
                    residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:)).^2,1));
                end

                kval(j,:) = sum(abs(xp(idx,:))) ./ sumxp;
            end

            sci(m:m+len) = (k.*max(kval)-1)./(k-1);

            cdistMatrix(m:m+len,1:length(classes)) = residuals;

            % Minimum residual error indicates to which class the object (face)
            % belongs.
            [val, ind] = min(residuals,[],2);
            minResiduals(m:m+len) = val;
            resultIds(m:m+len) = classes(ind);

            correctLabel = correctLabel + sum(resultIds(m:m+len) == fbgTestIds(m:m+len)');
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', m+len, length(fbgTestIds));
        end
        
    end
elseif fbgSRCMethod == SRC_OMP_BATCH
    fprintf(' Test:');    
    
        fprintf(' %0.6d/%0.6d', 0, length(fbgTestIds));
        for m = [1:batch:testLen testLen]
            len = min([batch-1, testLen-m]);

            if length(fbgTestIds) == 0 || len < 0, break; end

            %[xp,totIter] = GPSR_BCBm(fbgTestImgs(:,m:m+len),fbgTrainImgs,tau,len+1, 0);
            xp = ompbcb(fbgTrainImgs, fbgTestImgs(:,m:m+len), topRes, max([len 1]));
            xp = full(xp);
            residuals = zeros(len+1,length(classes));

            k = length(classes);
            kval = zeros(k,len+1);
            sumxp = sum(abs(xp));
            for j = 1:length(classes)
                if ~exist('useCache', 'var') || useCache
                    idx = cacheIdx{j};
                else
                    idx = find(fbgTrainIds == classes(j));
                end

                if occAI
                    residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:) - fbgTrainImgs(:,cacheIdxOcc)*xp(cacheIdxOcc,:)).^2,1)); ;
                else
                    %residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:)).^2,1));
                    residuals(:,j) = sqrt(sum((fbgTestImgs(:,m:m+len) - fbgTrainImgs(:,idx) * xp(idx,:)).^2,1));
                end

                kval(j,:) = sum(abs(xp(idx,:))) ./ sumxp;
            end

            sci(m:m+len) = (k.*max(kval)-1)./(k-1);

            cdistMatrix(m:m+len,1:length(classes)) = residuals;

            % Minimum residual error indicates to which class the object (face)
            % belongs.
            [val, ind] = min(residuals,[],2);
            minResiduals(m:m+len) = val;
            resultIds(m:m+len) = classes(ind);

            correctLabel = correctLabel + sum(resultIds(m:m+len) == fbgTestIds(m:m+len)');
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', m+len, length(fbgTestIds));
        end
        
        
% elseif fbgSRCMethod == SRC_OMP
%     d = double(fbgTrainImgs);
%     x = double(fbgTestImgs);
%     t = 35;
%     X = omp(d'*x,d'*d,t,'messages',1);
% 	fprintf(' ');
% 	
% 	for i = 1:testLen
% 		xp = full(X(:,i));
% 		
% 		computeSrcResiduals;
% 
% 		cdistMatrix(i,1:length(classes)) = residuals;
% 
% 		% Minimum residual error indicates to which class the object (face)
% 		% belongs.
% 		[val, ind] = min(residuals);
% 		minResiduals(i) = val;
% 		resultIds(i) = classes(ind);
% 
% 		if resultIds(i) == fbgTestIds(i)
% 			correctLabel = correctLabel + 1;
% 		end
%     end
elseif fbgSRCMethod == SRC_GPSRFAST_OCC || fbgSRCMethod == SRC_GPSRFAST_OCCe
    
    clearAe = 0;
    if ~exist('Ae', 'var')
        if exist('v', 'var')
            Ae = v;
        end
        clearAe = 1;
    end
    if fbgSRCMethod == SRC_GPSRFAST_OCCe
        if exist('v', 'var')
            Ae = eye(min(size(v)));
        else
            Ae = eye(size(fbgTrainImgs,1));
        end
    end
    
	fprintf(' Test:');
 	blocksize = floor(length(fbgTestIds)/20);
 	blocksize = max([min([blocksize 128]) 4]);
	[X,totIter] = GPSR_BCBm(fbgTestImgs,[fbgTrainImgs Ae],tau,blocksize);
	fprintf(' ');
	
	for i = 1:testLen
		xp = full(X(:,i));
		
		occ = xp(end-size(Ae,2)+1:end);
		
		residuals = zeros(1,length(classes));
		for j = 1 : length(classes)
			idx = cacheIdx{j};
			residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs(:,idx) * xp(idx) - Ae*occ);
		end
		
		% Compute SCI
		k = length(classes);
		kval = zeros(k,1);
		for j = 1:k
			idx = cacheIdx{j};
			kval(j) = sum(abs(xp(idx))) / sum(abs(xp));
		end
		sci(i) = (k*max(kval)-1)/(k-1);

		cdistMatrix(i,1:length(classes)) = residuals;

		% Minimum residual error indicates to which class the object (face)
		% belongs.
		[val, ind] = min(residuals);
		minResiduals(i) = val;
		resultIds(i) = classes(ind);

		if resultIds(i) == fbgTestIds(i)
			correctLabel = correctLabel + 1;
		end
    end
    
    if clearAe
        clear Ae;
    end
elseif fbgSRCMethod == SRC_LLC
    
%     X = LLC_coding_appr(fbgTrainImgs', fbgTestImgs', size(fbgTrainImgs,2), 1e-4)';
    
    fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
    for i = 1:testLen
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, length(fbgTestIds));
% 		xp = full(X(:,i));
        %xp = LLC_coding_appr(fbgTrainImgs', fbgTestImgs(:,i)', size(fbgTrainImgs,2), 1e-4)';
        xp = LLC_coding_appr(fbgTrainImgs', fbgTestImgs(:,i)', size(fbgTrainImgs,2), 1e-4)';
		
		computeSrcResiduals;

		cdistMatrix(i,1:length(classes)) = residuals;

		% Minimum residual error indicates to which class the object (face)
		% belongs.
		[val, ind] = min(residuals);
		minResiduals(i) = val;
		resultIds(i) = classes(ind);

		if resultIds(i) == fbgTestIds(i)
			correctLabel = correctLabel + 1;
		end
    end
elseif fbgSRCMethod == SRC_RSC
    
    fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
    for i = 1 : testLen
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, length(fbgTestIds));
        
        [id,val,xp,residuals] = RSC(fbgTrainImgs, fbgTrainIds, fbgTestImgs(:,i), tau);
        
        cdistMatrix(i,1:length(classes)) = residuals;

		minResiduals(i) = val;
		resultIds(i) = id;

        if i== 80
            stop = 1;
        end
		if resultIds(i) == fbgTestIds(i)
			correctLabel = correctLabel + 1;
        end
    end
else
	fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
	for i = 1:testLen
		fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, length(fbgTestIds));

		if fbgSRCMethod == SRC_GPSR || fbgSRCMethod == SRC_OCC
			xp = GPSR_BB(fbgTestImgs(:,i),fbgTrainImgs,tau,'Verbose',0);
		elseif fbgSRCMethod == SRC_YALL1
			opts.tol = 5e-8;
			opts.print = 0;
			[xp,Out] = yall1(fbgTrainImgs, R'\fbgTestImgs(:,i), opts); 
		elseif fbgSRCMethod == SRC_L1LS
			x0 = Ainv * fbgTestImgs(:,i);
			epsilon = 0.05;
			xp = l1qc_logbarrier(x0, fbgTrainImgs, [], fbgTestImgs(:,i), epsilon, 1e-3);
% 			xp = l1eq_pd(x0, fbgTrainImgs, [], fbgTestImgs(:,i), epsilon);
		elseif fbgSRCMethod == SRC_HOMO
			[xp,iter] = solvehomotopy(fbgTrainImgs, fbgTestImgs(:,i), 'lambda', tau, 'tolerance', reltol, 'maxiteration', numIter, 'stoppingcriterion', 3, 'isnonnegative', false);
        elseif fbgSRCMethod == SRC_DALM
            [xp,iter] = SolveDALM_fast(fbgTrainImgs, fbgTestImgs(:,i), 'lambda', tau, 'tolerance', reltol, 'maxiteration', numIter, 'stoppingcriterion', 3);
        elseif fbgSRCMethod == SRC_OMP
            %xp = solveomp(fbgTrainImgs,fbgTestImgs(:,i),64);
            xp = SolveOMP(fbgTrainImgs, fbgTestImgs(:,i), 'maxIteration', 1000, 'isNonnegative', 0, 'lambda', tau, 'stoppingcriterion', 3, 'tolerance', 0.5);
        elseif fbgSRCMethod == SRC_OMP_BATCH
            D = fbgTrainImgs;
            X = fbgTestImgs(:,1:16);
            T = 64;
            xp = omp(D'*X,D'*D,T,'messages',1); t3=toc;
		end

		computeSrcResiduals;

		cdistMatrix(i,1:length(classes)) = residuals;
%         residuals = residuals ./ sum(residuals);

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

if fbgSRCMethod == SRC_OCC
    fbgTrainImgs = fbgTrainImgs(:,1:end-length(fbgTrainImgs(:,1)));
end

distMatrix = [minResiduals resultIds' fbgTestIds];
cdistMatrix(1:end-1,end-1) = resultIds';
cdistMatrix(1:end-1,end) = fbgTestIds;
cdistMatrix(end,1:length(classes)) = classes;
custConf = sci;

fbgAccuracy = 0;
if testLen
  fbgAccuracy = 100 * correctLabel / testLen;
end