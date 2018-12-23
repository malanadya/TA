warning off;
% Normalize the columns of A to have unit l^2-norm.
for i = 1:size(fbgTestImgs,2)
    fbgTestImgs(:,i) = fbgTestImgs(:,i) / norm(fbgTestImgs(:,i));
end

fbgTrainImg = single(fbgTrainImgs);
fbgTestImgs = single(fbgTestImgs);
testLen = size(fbgTestImgs,2);
resultIds = zeros(1,length(testLen));
correctLabel = 0;

tau = 0.01; % Best >128 friends accuracy
tau = 0.000001;
tau = 0.1; % Best overall accuracy
tau = 0.25; % Best PR curve
tau = 0.4;
tau = 0.175;
tau = 0.001; % TAKES FOREVER!
tau = 0.3;
tau = 0.22;

tau = 0.01;

SRC_L1LS = 0;
SRC_GPSR = 2;
SRC_YALL1 = 1;
SRC_NS = 3;         % Nearest Subspace Implementation of SRC
SRC_L2 = 4;         % L2 Norm instead of l1-minimization
SRC_OCC = 5;
SRC_RWL2 = 6;
SRC_L2_NS = 7;

fbgSRCNormalize = 0;
fbgSRCMethod = SRC_GPSR;%SRC_L2;%SRC_GPSR;

% Let caller scripts specify the tau and SRC method
if exist('TAU', 'var')
	tau = eval(TAU);
end
if exist('SRCMETH', 'var')
	fbgSRCMethod = eval(SRCMETH);
end

if fbgSRCMethod == SRC_YALL1
    [Q, R] = qr(fbgTrainImgs',0);
    fbgTrainImgs = Q';% b = R'\b;
elseif fbgSRCMethod == SRC_L1LS || fbgSRCMethod == SRC_L2
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

classNorm = zeros(1,length(classes));
cacheIdx = {};
for j = 1 : length(classes)
    classNorm(j) = sum(fbgTrainIds == classes(j));
    cacheIdx{j} = find(fbgTrainIds == classes(j));
end

if fbgSRCMethod == SRC_L2_NS % ||fbgSRCMethod == SRC_NS
    for j = 1 : length(classes)
        cacheAinv{j} = pinv(fbgTrainImgs(:,cacheIdx{j}));
    end
end

% if fbgSRCMethod == SRC_RWL2
%     cacheAdot = [];
%     for i = 1 : size(fbgTrainImgs,1)
%         cacheAdot = [cacheAdot; repmat(fbgTrainImgs(i,:), size(fbgTrainImgs,1),1).*fbgTrainImgs];
%     end
% end

fprintf(' Test: %0.6d/%0.6d', 0, length(fbgTestIds));
cdistMatrix = zeros(length(fbgTestIds)+1,length(classes)+2);
sci = zeros(length(fbgTestIds),1);
for i = 1 : testLen
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
% 		xp = l1qc_logbarrier(x0, fbgTrainImgs, [], fbgTestImgs(:,i), epsilon, 1e-3);
        xp = l1eq_pd(x0, fbgTrainImgs, [], fbgTestImgs(:,i), epsilon);
    elseif fbgSRCMethod == SRC_L2
        % This is not sparse classification, but whatever
        xp = Ainv * fbgTestImgs(:,i);
    elseif fbgSRCMethod == SRC_RWL2
        w = ones(1,size(fbgTrainImgs,2));
        prevW = zeros(1,size(fbgTrainImgs,2));
        e0 = 1;
%         figure;
%         while e0 > tau
        for iCnt = 1 : 3
%             xp1 = pinv(diag(1./w.^2) * fbgTrainImgs')
            % Computation Step
            % xp = diag(1./w).^2 * fbgTrainImgs' * (fbgTrainImgs * diag(1./w).^2 * fbgTrainImgs')^-1 * fbgTestImgs(:,i);
            % matmul = bsxfun(@rdivide, fbgTrainImgs, w.^2);
            matmul = bsxfun(@times, fbgTrainImgs, w);
%             xp = matmul' * pinv(matmul * fbgTrainImgs') * fbgTestImgs(:,i);
%             newMat = reshape(sum(bsxfun(@times, cacheAdot, w),2), size(A,1), size(A,1));
%             temp = gauss_seidel(matmul * fbgTrainImgs', fbgTestImgs(:,i), 3);
            temp = gauss_seidel2(matmul * fbgTrainImgs', fbgTestImgs(:,i), zeros(1,length(fbgTestImgs(:,i))), 1e-05, 20);
            xp = matmul' * temp';
%             xp = matmul' * ((matmul * fbgTrainImgs')\fbgTestImgs(:,i));

            % Update Step
            r = sort(abs(xp), 'descend');
            e0 = 0;
%             e0 = min(e0, r(min(30,length(r))) / length(xp));
%             w = ((xp.^2 + e0.^2).^(-1/2))';
            % For some reason this works better than the above result
            w = sqrt(xp.^2 + e0.^2)';
        end
    elseif fbgSRCMethod == SRC_NS
        residuals = zeros(1,length(classes));
        % Compute the residuals
        for j = 1 : length(classes)
            idx = cacheIdx{j};
%             x0 = cacheAinv{j}* fbgTestImgs(:,i);
%             epsilon = 0.05;
%             xp = l1qc_logbarrier(x0, fbgTrainImgs(:,idx), [], fbgTestImgs(:,i), epsilon, 1e-20);
            xp = GPSR_BB(fbgTestImgs(:,i),fbgTrainImgs(:,idx),tau,'Verbose',0);
            
            residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs(:,idx) * xp);
        end
    elseif fbgSRCMethod == SRC_L2_NS
        residuals = zeros(1,length(classes));
        % Compute the residuals
        for j = 1 : length(classes)
            idx = cacheIdx{j};
            xp = cacheAinv{j}* fbgTestImgs(:,i);
            residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs(:,idx) * xp);
        end
    end
    
    if fbgSRCMethod ~= SRC_NS && fbgSRCMethod ~= SRC_L2_NS
        computeSrcResiduals;
	end
	
    
    cdistMatrix(i,1:length(classes)) = residuals;
    
    % Minimum residual error indicates to which class the object (face)
    % belongs.
    [val, ind] = min(residuals);
    minResiduals(i) = val;
    resultIds(i) = classes(ind);
	%plot(residuals), [fbgTestIds(i) classes(ind)]
	
    if resultIds(i) == fbgTestIds(i)
        correctLabel = correctLabel + 1;
	end
	
	% Calcualte sparsity concentration index (SCI)
	k = length(classes);
	kval = zeros(k,1);
	for j = 1:k
		idx = cacheIdx{j};
		kval(j) = sum(abs(xp(idx))) / sum(abs(xp));
	end
	sci(i) = (k*max(kval)-1)/(k-1);
    
%     sD1(i) = norm(abs(xp1) - abs(xp2));
%     sD2(i) = norm(abs(xp1) - abs(xp3));
%     sD3(i) = norm(abs(xp3) - abs(xp2));

% 	fprintf('Accuracy: %0.2f (%d out of %d)\n', correctLabel / i * 100, correctLabel, i);
end

if fbgSRCMethod == SRC_OCC
    fbgTrainImgs = fbgTrainImgs(:,1:end-length(fbgTrainImgs(:,1)));
end

distMatrix = [minResiduals resultIds' fbgTestIds];
%cdistMatrix(1:end-1,end-1) = residuals;
cdistMatrix(1:end-1,end) = fbgTestIds;
cdistMatrix(end,1:length(classes)) = classes;
custConf = sci;

fbgAccuracy = 100 * correctLabel / testLen;

warning on;