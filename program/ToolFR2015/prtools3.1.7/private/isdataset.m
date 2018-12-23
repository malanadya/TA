%ISDATASET
%
% True for class dataset or nonscalar double

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function n = isdataset(a)
if isa(a,'dataset') | (isa(a,'double') & length(a) > 1)
	n = 1;
else
	n = 0;
end
return
