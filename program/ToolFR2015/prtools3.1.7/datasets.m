%DATASETS Info on dataset class construction of PRTools
%
% This is not a command, just an information file.
%
% A dataset consists of a set of m objects, each given by k features. 
% In PRTools such a dataset is represented by a m x k matrix: m rows, 
% each containing an object vector of k elements. Usually a dataset is 
% labeled. An example of a definition is:
%
% A = dataset([1 2 3; 2 3 4; 3 4 5; 4 5 6],[3 3 5 5]')
% which defines a 4 x 3 dataset with 2 classes
%
% The 4 x 3 data matrix (4 objects given by 3 features) is accompanied 
% by a labels, connecting each of the objects to one of the two 
% classes, 3 and 5. Class labels can be numbers or strings and should 
% always be given as rows in the label list. If the label list is not 
% given all objects are given the default label 255. In addition it is 
% possible to assign labels to the columns (features) of a dataset:
%
% A = dataset(rand(100,3),genlab([50 50],[3 5]'),['r1';'r2';'r3'])
% which defines a 100 x 3 dataset with 2 classes
%
% The routine genlab generates 50 labels with value 3, followed by 50 
% labels with value 5. In the last term the labels (r1, r2, r3) for 
% the three features are set. The complete definition of a dataset is: 
%
% A = dataset(datamatrix,labels,featlist,prob,lablist)
%
% given the possibilitiy to set apriori probabilities for each of the 
% classes as defined by the labels given in lablist. The values in prob 
% should sum to one. If prob is empty or if it is not supplied the 
% apriori probabilities are computed from the dataset label 
% frequencies. If prob = 0 then equal class probabilities are assumed.
% Various items stored in a dataset can be retrieved by
%
% [nlab,lablist,m,k,c,prob,featlist] = dataset(A)
%
% in which nlab are numeric labels for the objects (1, 2, 3, ...) 
% referring to the true labels stored in the rows of lablist. The size 
% of the dataset is m x k, c is the number of classes (equal to 
% max(nlab)). Datasets can be combined by [A; B] if A and B have equal 
% numbers of features, and by [A B] if they have equal numbers of 
% objects. Creating subsets of datasets can be done by A(I,J) in which 
% I is a set of indices defining the desired objects and J is a set of 
% indices defining the desired features. In all these examples the 
% apriori probabilities set for A remain unchanged.
%
% The original datamatrix can be retrieved by double(A) or by +A. The 
% labels in the objects of A can be retrieved by getlab(A), which 
% is equivalent to lablist(nlab,:). The feature labels can be 
% retrieved by featlist = getfeat(A). Conversion by struct(A) makes 
% all fields in a dataset A accessible to the user. 
%
% Summary of routines that retrieve data stored in a dataset A by
% A = dataset(data,labels,featlist,prob,lablist,imheight)
%
% double(A), +A  - data
% getlab(A)      - labels
% getfeat(A)     - featlist
% getprob(A)     - prob
% getlablist(A)  - lablist
% getimheight(A) - imheight
% dataimsize(A)  - imagesize of images stored as objects or features in A
% classsizes(A)  - numbers of objects in each of the classes
%
% The order of classes returned by getprob and getlablist is the standard
% order used in PRTools and may differ from the one used in the definition of A.
