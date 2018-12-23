%SIGM Sigmoid map
% 
% 	W = W*sigm
% 	B = sigm(A)
% 
% Sigmoidal transformation from map to classifier, producing 
% posterior probability estimates. 
% See also datasets, mappings, classc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = sigm(a)
if nargin == 0
	w = mapping('sigm','fixed');
else
	w = 1./(1+exp(-a));
end
return

