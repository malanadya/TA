opt.results.identities = [200]; 
opt.results.repetitions = [5];
opt.results.path = 'ENTER RESULTS PATH HERE';
opt.results.fileName = 'pflfw';
opt.results.title = 'pflfw';
fileSpecifier = 'fbacc_pflfw_hog_gabor_lbp_';
opt.results.algorithms = {
    {'Nearest Neighbor', [fileSpecifier 'NN_results_nn'], 0};
    {'LLC', [fileSpecifier 'LLC_results_llc'], 0};
    {'KNN-SRC', [fileSpecifier 'KNN-SRC_results_knnsrc'], 0};
    {'LRC', [fileSpecifier 'LRC_results_lrc'], 0};
    {'L2', [fileSpecifier 'L2_results_l2'], 0};
    {'SVM', [fileSpecifier 'SVM_results_svm'], 0};
    {'LASRC', [fileSpecifier 'LASRC_results_lasrc'], 1};
};