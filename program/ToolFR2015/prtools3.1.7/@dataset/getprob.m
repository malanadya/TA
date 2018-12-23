%GETLAB Get class probabilities of dataset
%
%	prob = getlab(a)
%
% Returns the class probabilities as defined for the dataset a.
% Note that if these are not set then prob = [] is returned.
%
% See datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function prob = getlab(a)
prob = a.p;
