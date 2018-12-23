%GETLAB Get label list of dataset
%
%	lablist = getlablist(a)
%
% Returns the label list of a dataset a.
% 
% See datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function lablist = getlablist(a)
lablist = a.ll{1};
