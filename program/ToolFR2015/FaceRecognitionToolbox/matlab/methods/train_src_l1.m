train_scr;

prune = 0;
try, prune = opt.algorithm.src.prune.enable; end
lsrcDown = 0;
try, lsrcDown = opt.algorithm.src.prune.lsrcDown; end
algo = 'src_l2';
try, algo = opt.algorithm.src.prune.algorithm; end;

lasrcfast = 0;
try, lasrcfast = opt.algorithm.src.lasrc.fast; end;
lasrcdims = [512 512 512];
try, lasrcdims = opt.algorithm.src.lasrc.dims; end

if lasrcfast >= 1
    fprintf('%d %d\n', size(fbgTrainImgs));
    fbgTrainImgsWhole = fbgTrainImgs;
    %fbgTrainImgs = [];
    %for i = 1:length(lasrcdims)
        %fbgTrainImgs = [fbgTrainImgs fbgTrainImgsWhole((i-1)*lasrcdims(1)+1
    if lasrcfast == 2
         fbgTrainImgs = [fbgTrainImgs(1:256,:); fbgTrainImgs(512+1:512+256,:); fbgTrainImgs(512*2+1:512*2+256,:)];
    elseif lasrcfast == 3
         fbgTrainImgs = [fbgTrainImgs(1:192,:); fbgTrainImgs(512+1:512+192,:); fbgTrainImgs(512*2+1:512*2+192,:)];
    elseif lasrcfast == 5
         fbgTrainImgs = [fbgTrainImgs(1:170,:); fbgTrainImgs(512+1:512+170,:); fbgTrainImgs(512*2+1:512*2+170,:)];
    end
    %end
end

if prune && lsrcDown && strcmp(algo, 'src_l2')
    
    doCosine = 0;
    try, doCosine = opt.algorithm.src.prune.doCosine; end

    if ~doCosine && (~exist('Ainv', 'var') || (exist('clearLibsvm', 'var') && clearLibsvm == 0))
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
end