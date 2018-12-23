%Pattern Recognition Tools (PRTOOLS 3.1.7)
% Version 1 February 2002 (after PRSD course)
%
%Datasets and Mappings
%---------------------
%dataset     Define and retrieve dataset from datamatrix and labels
%datasets    List information on datasets (just help, no command)
%getlab      Retrieve object labels from datasets and mappings
%getfeat     Retrieve feature labels from dataset
%getlablist  Retrieve names of classes
%classsizes  Retrieves sizes of classes
%getprob     Retrieves class prior probabilities
%genlab      Generate dataset labels
%mapping     Define and retrieve mapping and classifier from data
%mappings    List information on mappings (just help, no command)
%renumlab    Convert labels to numbers
%matchlab    Match different labelings
%
%Data Generation 
%---------------
%gauss       Generation of multivariate Gaussian distributed data
%gencirc     Generation of a one-class circular dataset
%gendat      Generation of classes from given data set
%gendatb     Generation of banana shaped classes
%gendatc     Generation of circular classes
%gendatd     Generation of two difficult classes
%gendath     Generation of Higleyman classes
%gendatk     Nearest neighbour data generation
%gendatl     Generation of Lithuanian classes
%gendatm     Generation of 8 2d classes
%gendatp     Parzen density data generation
%gendats     Generation of two Gaussian distributed classes
%gendatt     Generation of testset from given dataset
%prdata      Read data from file
%seldat      Select classes / features / objects from dataset
%
%Linear and Quadratic Classifiers 
%--------------------------------
%klclc       Linear classifier by KL expansion of common cov matrix
%kljlc       Linear classifier by KL expansion on the joint data
%loglc       Logistic linear classifier
%fisherc     Minimum least square linear classifier
%ldc         Normal densities based linear (muli-class) classifier
%nmc         Nearest mean linear classifier
%nmsc        Scaled nearest mean linear classifier
%perlc       Perceptron linear classifier
%persc       Perceptron linear classifier
%pfsvc       Pseudo-Fisher support vector classifier
%qdc         Normal densities based quadratic (multi-class) classifier
%udc         Uncorrelated normal densities based quadratic classifier
%quadrc      Quadratic classifier
%polyc       Add polynomial features and run arbitrary classifier
%
%classc      Converts a mapping into a classifier
%classd      General classification routine for trained classifiers
%testd       General error estimation routine for trained classifiers
%
%Other Classifiers 
%-----------------
%knnc        k-nearest neighbour classifier (find k, build classifier)
%knn_map     k-nearest neighbour mapping
%testk       Error estimation for k-nearest neighbour rule
%
%parzenc     Parzen density based classifier
%parzenml    Optimization of smoothing parameter in Parzen density estimation.
%parzen_map  Parzen mapping
%testp       Error estimation for Parzen classifier
%
%edicon      Edit and condense training sets
%
%treec       Construct binary decision tree classifier
%tree_map    Classification with binary decision tree
%
%bpxnc       Train feed forward neural network classifier by backpropagation
%lmnc        Train feed forward neural network by Levenberg-Marquardt rule
%neurc       Automatic Neural Network Classifier (using lmnc)
%rbnc        Train radial basis neural network classifier
%rnnc        Random neural network classifier
%
%subsc       Subspace Classifier
%svc         Support vector classifier
%
%Normal Density Based Classification
%-----------------------------------
%distmaha    Mahalanobis distance
%normal_map  Normal density mapping
%meancov     Estimation of means and covariance matrices from multiclass data
%nbayesc     Bayes classifier for given normal densities
%ldc         Normal densities based linear (muli-class) classifier
%qdc         Normal densities based quadratic (multi-class) classifier
%udc         Uncorrelated normal densities based quadratic classifier
%testn       Error estimate of discriminant on normal distributions
%
%Feature Selection
%-----------------
%feateval    Evaluation of a feature set
%featrank    Ranking of individual feature permormances
%featselb    Backward feature selection
%featself    Forward feature selection
%featseli    Feature selection on individual performance
%featselm    Feature selection map, general routine for feature selection
%featselo    Branch and bound feature selection
%featselp    Floating forward feature selection
%featselm    Feature selection map, general routine for feature selection
%
%Classifiers and tests (general)
%-------------------------------------
%classim     Classify image using a given classifier
%classc      Convert mapping to classifier
%classd      General classification routine for trained classifiers
%cleval      Classifier evaluation (learning curve)
%clevalb     Classifier evaluation (learning curve), bootstrap version
%clevalf     Classifier evaluation (feature size curve)
%confmat     Computation of confusion matrix
%crossval    Crossvalidation 
%cnormc      Normalisation of classifiers
%mclassc     Computation of multi-class classifier from 2-class discriminants
%reject      Compute error-reject trade-off curve
%roc         Receiver-operator curve
%testd       General error estimation routine for trained classifiers
%
%Mappings
%--------
%classs      Linear mapping by classical scaling
%cmapm       Compute some special maps
%featselm    Feature selection map, general routine for feature selection
%fisherm     Fisher mapping
%invsigm     Inverse sigmoid map
%klm         Decorrelation and Karhunen Loeve mapping (PCA)
%klms        Scaled version of klm, useful for prewhitening
%lmnm        Levenberg-Marquardt neural net diabolo mapping
%maf         Maximum autocorrelation mapping (ICA)
%mds         Non-linear mapping by multi-dimensional scaling (Sammon)
%nlfisherm   Nonlinear Fisher mapping
%normm       Object normalization map
%pca         Principal Component Analysis
%proxm       Proximity mapping and kernel construction
%reducm      Reduce to minimal space mapping
%scalem      Compute scaling data
%sigm        Simoid mapping
%spatm       Augment image dataset with spatial label information
%subsm       Subspace mapping
%svm         Support vector mapping, useful for kernel PCA
%
%Classifier combiners
%--------------------
%baggingc    Bootstrapping and aggregation of classifiers
%majorc      Majority classifier combiner (Voting)
%maxc        Maximum classifier combiner
%minc        Minimum classifier combiner
%meanc       Mean classifier combiner
%medianc     Median classifier combiner
%prodc       Product classifier combiner
%traincc     Train combining classifier
%parsc       Parse classifier or map
%rsubc       Random Subspace Classifier
%
%Image operations
%----------------
%classim     Classify image using a given classifier
%dataim      Image operation on dataset images
%data2im     Convert dataset to image
%getimheight Retrieve image height of images in datasets
%dataimsize  Retrieve image size of images in datasets
%datfilt     Filter dataset image
%datgauss    Filter dataset image by Gaussian filter
%datunif     Filter dataset image by uniform filter
%im2obj      Convert image to object in dataset
%im2feat     Convert image to feature in dataset
%image       Display images stored in dataset
%show        Display of dataset images and mapping eigen-images
%spatm       Augment image dataset with spatial label information
%
%Clustering and distances
%------------------------
%distm       Distance matrix between two data sets.
%emclust     Expectation - maximization clustering
%proxm       Proximity mapping and kernel construction
%hclust      Hierarchical clustering
%kcentres    k-centres clustering
%kmeans      k-means clustering
%modeseek    Clustering by modeseeking
%
%Plotting
%--------
%gridsize    Set gridsize of scatterd, plotd and plotm plots
%plotd       Plot discriminant function for two features
%plot2       Plot 2d function
%plotf       Plot feature distribution
%plotm       Plot mapping
%plotdg      Plot dendrgram (see hclust)
%scatterd    Scatterplot
%
%Examples
%--------
%prex1       Classifiers and scatter plot
%prex2       Plot learning curves of classifiers
%prex3       Multi-class classifier plot
%prex4       Classifier combining
%prex5       Use of images and eigenfaces
%prex6       Multi-band image segmentation
%prex7       Independent Component Analysis of multi-band image
%
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands
