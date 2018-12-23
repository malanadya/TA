options = {};

opt.dataset.imagePath = 'ENTER IMAGE PATH HERE';
opt.dataset.featurePath = 'ENTER FEATURE PATH HERE';
opt.dataset.name = 'pflfw_hog_gabor_lbp';

opt.dataset.identities = 200;
opt.dataset.repetitions = 5;
opt.dataset.trainPercent = 75;
opt.dataset.enableDistract = 1;
opt.dataset.forceDistractFraction = 0;

opt.image.forceGrayscale = 1;
opt.image.cropFraction = 1/5;
opt.image.resizeWidth = 0;
opt.image.cropBorder = 0;

opt.dataset.precision = 'single';

opt.dataset.pca.numDims = 1536;
opt.dataset.pca.maxMemGB = 0.5; 

opt.features = {hog, gabor, lbp};

options{end+1} = opt;