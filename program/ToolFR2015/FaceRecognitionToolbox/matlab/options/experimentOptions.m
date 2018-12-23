options = {};

opt = struct;
opt.skipDone = 1;

% Dataset Parameters
opt.dataset.featurePath = 'ENTER FEATURE PATH HERE';
opt.dataset.identities = 200;
opt.dataset.repetitions = 5;
opt.dataset.name = 'pflfw_hog_gabor_lbp'; % Designator for dataset (i.e. fbdataset, pubfig, etc)

% Output Parameters
opt.results.path = 'ENTER RESULTS PATH HERE';
opt.results.name = 'pflfw';


% Define Algorithms to Run
% l1-solvers available: 'GPSR', 'ALM', 'Homotopy', 'l1magic', or 'L1_LS'
algorithms = {
    {'NN', 'results_nn'};
    {'LLC', 'results_llc', 'K', 64};
    {'KNN-SRC', 'results_knnsrc', 'K', 64, 'Solver', 'GPSR', 'Tau', 0.01};
    {'LRC', 'results_lrc', 'CapTraining', 100};
    {'L2', 'results_l2', 'CapTraining', 100};
    {'LASRC', 'results_lasrc', 'K', 64, 'Solver', 'GPSR', 'Tau', 0.01};
    {'SVM', 'results_svm', 'Slack', 1};
% More algorithms that may need more work to run (i.e. mex compile, or take
% a long time to run, etc)
%     {'SRC', 'results_src_gpsr', 'Solver', 'GPSR', 'Tau', 0.05, 'Tol', 1e-6};
%     {'SVM-KNN', 'results_svmknn', 'K', 64};
%     {'SRC', 'results_src_homotopy', 'Solver', 'Homotopy', 'Tau', 0.05, 'Tol', 1e-3};
%     {'SRC', 'results_src_gpsr', 'Solver', 'GPSR', 'Tau', 0.05, 'Tol', 1e-6};
%     {'MTJSRC', 'results_mtjsrc', 'Iter', 2, 'FeatLens', [665 665 665]};
%     {'OMP', 'results_omp', 'K', 64};
%     {'CRC_RLS', 'results_crc_rls', 'RegTerm', -1, 'CapTraining', 100};
    };

options = fbCreateOptions(algorithms, opt, options);