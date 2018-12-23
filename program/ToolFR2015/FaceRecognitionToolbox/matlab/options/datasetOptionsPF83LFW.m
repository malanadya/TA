options = {};

opt.dataset.imagePath = 'ENTER IMAGE PATH HERE';
opt.dataset.featurePath = 'ENTER FEATURE PATH HERE';
opt.dataset.name = 'pf83lfw_hog_gabor_lbp';

opt.dataset.identities = 83;
opt.dataset.repetitions = 1;
opt.dataset.trainPercent = 75;
opt.dataset.enableDistract = 1;
opt.dataset.forceDistractFraction = 0;

opt.image.forceGrayscale = 1;
opt.image.cropFraction = 1/6;
opt.image.resizeWidth = 0;
opt.image.cropBorder = 0;

opt.dataset.precision = 'single';

opt.dataset.pca.numDims = 1024;
opt.dataset.pca.maxMemGB = 0.5; 

opt.features = {hog, gabor, lbp};

options{end+1} = opt;