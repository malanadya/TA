%NEURC Automatic Neural Network Classifier
% 
% 	W = neurc(A,n)
% 
% Automatic neural network classifier based on a feedforward network 
% with n hidden units (default n = 5) and a Levenberg-Marquardt 
% optimization. Training is stopped when the performance on an 
% artificially generated tuning set of 1000 samples per class based 
% on k-nearest neighbour interpolation does not improve anymore. The 
% default value of n is 5. In future version this might be replaced 
% by an automaticly optimised value.
% 
% See also datasets, mappings, lmnc, gendatk

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = neurc(a,n);
if nargin == 1, n = 5; end
t = gendatt(a,1000,'knn',2,1);
w = lmnc(a,n,[],[],t);
return

