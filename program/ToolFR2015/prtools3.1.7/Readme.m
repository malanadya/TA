% PRTools3.0 December 1999
% 
% PRTOOLS is a basic set of statistical pattern recognition
% tools under Matlab. Not all commands are entirely tested.
%
% It is heavily upgraded from the previous version, November 1997
%
% The main change is the use of "classes' and 'objects' offered
% by Matlab-5 (Don't confuse them with the pattern recognition
% classes and objects!). This simplifies the use, but may be
% hard to understand for old users. Moreover, it makes PRTools3.0
% completely incompatible with old versions. 
%
% There are two of these class-constructors: datasets and mappings,
% the basic elements of pattern recognition. As use is made of
% structures (entirely hidden for the user), they contain all types
% of information that should be transferred otherwise explicitely
% by the user: labels, sizes, weigths, mapping types, etcetera.
%
% What we can do now are defining datasets by
%   A = dataset(a,labels);
% use it for training by defining a mapping by
%   W = ldc(A);
% which may also be written as
%   W = A*ldc;
% and use it for testing by:
%   e = A*W*testd;
% This can be read as: map the dataset A on W (i.e. a space constructed
% by class memberships) and test it (count the errors).
% Mappings can be combined sequentially (W = W1*W2), by stacking
% ([W = [W1 W2 W3]) and in parallel (W = [W1; W2; W3]). This facilitates
% the construction of combined classifiers, e.q. W = maxc([W1 W2 W3]).
%
% A number of routines has been renamed, e.g.:
%   nlc     : ldc
%   nqc     : qdc
%   mlslc   : fisherc
%   nmlc    : nmc
% Others are combined or have been moved outside the user sight into the
% private directory. Many routines have been added. See the Contents file.
%
% PRTools3.1, January 2000
%
% For affine mapping and normalizing mappings the multiplicative output
% constant w.v is now integrated in the mapping coefficients. w.v is set
% to one.
%
% Untrained mappings are no longer empty, so now isempty(fisherc) is 0.
% These mappings can now be detected by the new routine 'istrained', so
% istrained(fisherc) is 0.
%
% The display command for datasets has been changed such that it returns
% the actual number of classes available in the dataset.
%
% New commands:
%	seldat:   Select classes / features / objects from dataset
%   classim:  Classify image using a given classifier
%   clevalf:  Classifier evaluation (feature size curve)
%   cnormc:   Renamed copy of normc
%   emclust:  Expectation - Maximization Clustering
%   spatm:    Augment image dataset with spatial label information
%   nlfisherm:Renamed copy of nlklm
%
% PRTools3.1.2, January 2001
%
% The dataset structure changed in order to speed up the handling of labels.
% This should not effect the calls as it is intended to be upwards compatible.
% Newly created datasets, however, cannot be used under previous versions
% of PRTools.
%
% The confmat command changed slightly to enable a more general use. As a
% result the number of errors for the specific useage in which the two
% labellists are identical is not returned anymore.
%
% A new command matchlab is added to rotate labels for optimal match.
%
% PRTools3.1.3, July 2001
%
% New commands
%   pca:      Principal component analysis (replaces overloaded procedure by klm)
%   maf:      Maximum autocorrelation mapping, (pca for multi-band images)
%
% Consequently, some of the old, overloaded and confusing possiblities in klm
% are removed.
%
% PRTools3.1.4, August 2001
%
%   some bugs are removed in @dataset/subsasgn.m and @dataset/dataset.m
%   all relating to the erroneous working of expressions like
%   A([1 2 3],:) = []; A(:,[1 2 3]);
%   if A is a dataset.
%
%   kljlc:   bug removed
%   gauss:   label generation improved
%   gendats: labels changed from numeric to character
%   featsel* redundant output suppressed
%
% PRTools3.1.5, August 2001
%
%   knnc:    Makes no use anymore of prior probabilities.
%
% New command
%   getprob: Retrieves dataset prior probabilities
%
% PRTools3.1.6, September 2001
%
%   normal_map: now generates scaled densities
%   qdc:        now also in 2-class problems based on densities
%   plotm:      internal scaling improved. Parameter added for
%               selecting contour.
%   scatterd:   extended, a.o. with 3d plot
%   distm:      now returns a dataset
%   gendat:     relative class sizes supported
%
% New commands:
%
%   subsc:    Subspace Classifier
%   quadrc:   Quadratic classifier (original 2-class qdc)
%   mclassc:  Multi-class classifier by 2-class discriminants
%   classsizes: Returns sizes of classes in a dataset
%   getlablist: Returns label list of a dataset
%               See 'help datasets' for all means to retrieve data stored
%               in a dataset.
%   mds:      Non-linear mapping by multi-dimensional scaling (Sammon)
%   classs:   Multi-dimensional mapping by classical scaling
%
% *************************************************************
%
% More information can be found by
%   help prtools
%   help datasets
%   help mappings
% or in the manual (http://www.ph.tn.tudelft.nl/~bob/postscript/PRTools3.ps)
%
% This software can be used freely for inspection and academic research.
% Please refer to
%
%   R.P.W. Duin, PRTools 3, A Matlab Toolbox for Pattern Recognition, Delft
%   University of Technology, January 2000
%
% if it has been useful to you. If you like to use the toolbox for commercial
% purposes, please contact me.
%
% Bob Duin
%
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

