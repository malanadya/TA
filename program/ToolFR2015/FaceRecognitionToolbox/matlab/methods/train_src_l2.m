train_scr;

doCosine = 0;
try, doCosine = opt.algorithm.src.prune.doCosine; end

if ~doCosine && (~exist('Ainv', 'var'))% || (exist('clearLibsvm', 'var') && clearLibsvm == 0))
	kappa = 0;
    try, kappa = opt.algorithm.src.l2.regularization; end;
    if kappa == -1
        kappa = 0.001*length(fbgTrainImgs)/700;
    end
    if kappa > 0
        [u,s,v] = svd(fbgTrainImgs,'econ');
        d = diag(s);
        d = d ./ (d.^2 + kappa^2);
        Ainv = v*diag(d)*u';
    else
        Ainv = pinv(fbgTrainImgs);
	end
	%fprintf(' %f kappa ', kappa);
end