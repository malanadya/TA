%INVSIGM Inverse sigmoid map
% 
% 	W = W*invsigm
% 	B = invsigm(A)
% 
% Inverse sigmoidal transformation from classifier to map, transforming 
% posterior probabilities into distances.
%
% See also datasets, mappings, classc, sigm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = invsigm(a)
if nargin == 0
	w = mapping('invsigm','fixed');
else
	w = log(a+realmin) - log(1-a+realmin);
end
return

