opt.results.identities = [83]; 
opt.results.repetitions = [1];
opt.results.path = 'INSERT RESULTS DIRECTORY HERE';
opt.results.fileName = 'pf83lfw';
opt.results.title = 'pf83lfw';
fileSpecifier = 'fbacc_pf83lfw_hog_gabor_lbp_';
opt.results.algorithms = {
    {'Nearest Neighbor', [fileSpecifier 'NN_results_nn'], 0};
    {'LLC', [fileSpecifier 'fbacc_pflfw_hog_gabor_lbp_LLC_results_llc'], 0};
    {'KNN-SRC', [fileSpecifier 'fbacc_pflfw_hog_gabor_lbp_KNN-SRC_results_knnsrc'], 0};
    {'LRC', [fileSpecifier 'fbacc_pflfw_hog_gabor_lbp_LRC_results_lrc'], 0};
    {'L2', [fileSpecifier 'fbacc_pflfw_hog_gabor_lbp_L2_results_l2'], 0};
    {'SVM', [fileSpecifier 'fbacc_pflfw_hog_gabor_lbp_SVM_results_svm'], 0};
    {'LASRC', [fileSpecifier 'fbacc_pflfw_hog_gabor_lbp_LASRC_results_lasrc'], 1};
};
