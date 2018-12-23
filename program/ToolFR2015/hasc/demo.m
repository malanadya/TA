%% DEMO HASC (Heterogeneous Auto-Similarities of Characteristics)
% Marco San Biagio      Version 1.00
% Copyright 2013 Marco San Biagio.  [Marco.SanBiagio-at-iit.it]
% Please email me if you have questions.
%
% Abstract:
% Capturing the essential characteristics of visual objects by considering how their features are inter-related
% is a recent philosophy of object classification. In this paper, we embed this principle in a novel image descriptor,
% dubbed Heterogeneous Auto-Similarities of Characteristics (HASC). HASC is applied to heterogeneous dense features
% maps, encoding linear relations by covariances and nonlinear associations through information-theoretic measures
% such as mutual information and entropy. In this way, highly complex structural information can be expressed in a compact,
% scale invariant and robust manner. The effectiveness of HASC is tested on many diverse detection and classification
% scenarios, considering objects, textures and pedestrians, on widely known benchmarks (Caltech-101, Brodatz,
% Daimler Multi-Cue). In all the cases, the results obtained with standard classifiers witness the superiority of HASC
% with respect to the most adopted local feature descriptors nowadays, such as SIFT, HOG, LBP and feature covariances.
% In addition, HASC sets the state-of-the-art on the Brodatz texture dataset and the Daimler Multi-Cue pedestrian
% dataset, without exploiting ad-hoc sophisticated classifiers.
%
% [1] M. San Biagio, M. Crocco, M. Cristani, S. Martelli and V. Murino
%     Heterogeneous Auto-Similarities of Characteristics (HASC): Exploiting Relational Information for Classification
%     International Conference on Computer Vision, Proceedings of. 2013.
%
% This demo is optimezed for Matlab R2012b for Windows and Linux 32/64 bit Versions.

opt.bin = 28;                                      % Number of bins used to evaluate histograms in EMI computation
opt.NoFeat = 6;                                    % number of low level features
opt.DescrDim = (opt.NoFeat^2+opt.NoFeat)/2;        % dimension of the HASC descriptor

%% Read an example image
img = imread('./Lena.png');

%% Extracting Features (for each image)
feat = GetFeatures(img, opt);

%% Features Normalization (over all images)
% If you want to calculate the EMI matrices over a set of images 
% Max Vector and Min Vector have to be calculated for each feature over all
% images. If you have N images and d features, at the end you must have a Max and
% Min vector of size 1 x d
[feat,max_vector,min_vector] = GetFeatNormalization(feat, opt);

%% Get Covariance descriptor
CovVec = GetCovariance(feat);

%% Get EMI descriptor
EMIVec = GetEntropyMI(feat, max_vector, min_vector, opt);

HASC = [CovVec EMIVec];

clear CovVec EMIVec feat img max_vector min_vector opt

