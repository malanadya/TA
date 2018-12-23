%PARSC Pars classifier
% 
% 	parsc(w)
% 
% Displays the type and, for combining classifiers, the structure of 
% the mapping w.
% 
% See also mappings

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function parsc(W,space)
if ~isa(W,'mapping') return; end
if nargin == 1, space = ''; end
display(W,space);
w = double(W);
if iscell(w)
	space = [space '  '];
	for i=1:length(w)
		parsc(w{i},space)
	end
end
