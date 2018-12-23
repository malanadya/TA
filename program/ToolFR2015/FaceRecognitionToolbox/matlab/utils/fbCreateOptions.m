function options = fbCreateOptions(algorithms, opt, options)

origOpt = opt;
for aNum = 1 : length(algorithms)
    opt = origOpt;
    
    if mod(length(algorithms{aNum}),2)
        error('Wrong Parameters: Incorrect number of input/value pairs.');
    end
    
%     params = containers.Map();
%     for pNum = 3 : 2 : length(algorithms{aNum})
%         algorithms(aNum) = (pNum:pNum+1);
%     end
    
    opt = parseAndInitAlgorithm(algorithms{aNum}{1}, opt);
    opt.results.name = algorithms{aNum}{2};
    
    for pNum = 3 : 2 : length(algorithms{aNum})
        opt = parseParameter(algorithms{aNum}(pNum:pNum+1),opt);
    end
%     
%     opt = addDefaultParameters(opt);
    
    options{end+1} = opt;
end

return

function name = mapSolverToName(solver)
switch solver
    case {'Homotopy'}
        name = 'SRC_HOMO';
    case {'GPSR'}
        name = 'SRC_GPSRFAST';
    case {'L1_LS'}
        name = 'SRC_L1LS_REAL';
    case {'l1magic'}
        name = 'SRC_L1LS';
    case {'ALM'}
        name = 'SRC_DALM';
    otherwise
        error(sprintf('Solver %s not found!', solver));
end
return

function opt = parseAndInitAlgorithm(algo, opt)

defaultK = 64;
defaultBatch = 16;
defaultTau = '0.01';

opt.algorithm.friendlyName = algo;

switch algo
    case {'NN'}
        opt.algorithm.name = 'nn';
	case {'SVM'}
        opt.algorithm.name = 'liblinear';
        opt.algorithm.svm.slackC = 1;
	case {'SVM-KNN'}
        opt.algorithm.name = 'src_l1';
        opt.algorithm.src.method = 'SRC_SVM';
        opt.algorithm.src.prune.enable = 1;
        opt.algorithm.src.prune.algorithm = 'nn';
        opt.algorithm.src.prune.topRes = defaultK;
        opt.algorithm.src.prune.lsrcDown = 1;
        opt.algorithm.src.prune.svmOneVsAll = 1;
        opt.algorithm.src.prune.svmProb = 1;
        opt.algorithm.l1.batchSize = defaultBatch;
	case {'SRC'}
        opt.algorithm.name = 'src_l1';
        opt.algorithm.src.method = 'SRC_GPSRFAST'; 
        opt.algorithm.src.prune.enable = 0;
        opt.algorithm.src.tol = '1e-6';
        opt.algorithm.src.tau = 0.05;
	case {'MTJSRC'}
        opt.algorithm.name = 'mtjsrc';
        opt.algorithm.mtjsrc.iterations = 2;
        opt.algorithm.mtjsrc.featLens = [];
    case {'LLC'}
        opt.algorithm.name = 'src_l1';
        opt.algorithm.src.method = 'SRC_LLC'; 
        opt.algorithm.src.prune.enable = 1;
        opt.algorithm.src.prune.algorithm = 'nn';
        opt.algorithm.src.prune.topRes = defaultK;
        opt.algorithm.src.prune.lsrcDown = 1;
    case {'OMP'}
        opt.algorithm.name = 'src_l1';
        opt.algorithm.src.method = 'SRC_OMP_BATCH'; 
        opt.algorithm.src.prune.enable = 0;
        opt.algorithm.src.prune.algorithm = 'nn';
        opt.algorithm.src.prune.topRes = defaultK;
        opt.algorithm.src.prune.lsrcDown = 1;
        opt.algorithm.l1.batchSize = defaultBatch;
	case {'KNN-SRC'}
        opt.algorithm.name = 'src_l1';
        opt.algorithm.src.method = 'SRC_GPSR'; % Which SRC algorithm to use
        opt.algorithm.src.prune.enable = 1;
        opt.algorithm.src.prune.algorithm = 'nn';
        opt.algorithm.src.prune.topRes = defaultK;
        opt.algorithm.src.prune.lsrcDown = 1;
        opt.algorithm.src.tau = defaultTau; 
	case {'LRC'}
        opt.algorithm.name = 'src_l2_ns'; 
    case {'L2'}
        opt.algorithm.name = 'src_l2'; 
        opt.algorithm.src.l2.regularization = 0;
	case {'CRC_RLS'}
        opt.algorithm.name = 'src_l2'; % Which algorithm to run
        opt.algorithm.src.l2.regularization = -1;
    case {'LASRC'}
        opt.algorithm.name = 'src_l1';
        opt.algorithm.src.method = 'SRC_GPSR'; 
        opt.algorithm.src.prune.enable = 1;
        opt.algorithm.src.prune.algorithm = 'src_l2';
        opt.algorithm.src.prune.topRes = defaultK;
        opt.algorithm.src.prune.lsrcDown = 1;
        opt.algorithm.src.tau = defaultTau;
    otherwise
        error(sprintf('Wrong Parameters: Unsupported algorithm %s!', algo));
end

opt.algorithm.l2.batchSize = defaultBatch;%sprintf('''%d''', defaultBatch);
opt.algorithm.nn.batchSize = defaultBatch;

return



function opt =  parseParameter(param,opt)

switch param{1}
    case 'Solver'
        opt.algorithm.src.method = mapSolverToName(param{2});
    case 'Tau'
        opt.algorithm.src.tau = param{2};%sprintf('''%d''', param{2});
    case 'K'
        opt.algorithm.src.prune.topRes = param{2};
    case 'CapTraining'
        opt.dataset.decimate = param{2};
        opt.dataset.decimateTrainOnly = 1;
    case 'Tol'
        opt.algorithm.src.tol = param{2};%sprintf('''%f''', param{2});
    case 'Slack'
        opt.algorithm.svm.slackC = param{2};
    case 'RegTerm'
        opt.algorithm.src.l2.regularization = param{2};
    case 'Iter'
        opt.algorithm.mtjsrc.iterations = param{2};
    case 'FeatLens'
        opt.algorithm.mtjsrc.featLens = param{2};
    otherwise
        error(sprintf('Wrong Parameters: Unknown parameter %s!', param{1}));
end

return

return