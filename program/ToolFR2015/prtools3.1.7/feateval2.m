%FEATEVAL Evaluation of feature set
% 
% 	J = feateval(A,crit,T)
% 
% Evaluation of features by the criterion crit, using objects in the 
% dataset A. The larger J, the better. Resulting J-values are
% incomparable over the following methods:
% 
% 	crit='maha-s': sum of estimated Mahalanobis distances.
% 	crit='maha-m': minimum of estimated Mahalanobis distances.
% 	crit='eucl-s': sum of squared Euclidean distances.
% 	crit='eucl-m': minimum of squared Euclidean distances.
% 	crit='NN'    : 1-Nearest Neighbour leave-one-out
% 			classification performance (default).
% 			(performance = 1 - error). 
% 
% crit can also be any untrained classifier, e.g. ldc([],1e-6,1e-6). 
% The classification error is used for a performance estimate. If 
% supplied, the dataset T is used for obtaining an unbiased estimate 
% the performance of classifiers trained with the dataset A. If T is 
% not given, the apparent performance on A is used. 
% 
% See also datasets, featselo, featselb, featself, featselp, 
% featselm, featrank

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function J = feateval2(a,crit,kk,t)
[nlaba,lablista,ma,k,c] = dataset(a);
			J =1 - testk(a,kk);

