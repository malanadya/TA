%TRAINCC Train combining classifier if needed
%
%	W = traincc(A,W,cclassf)
%
% The combining classifier cclassf is trained by dataset A*W if it needs
% training. W is typically a set of stacked or parallel classifiers to
% be combined. If cclassf is one of the fixed combining rules like maxc
% training is skipped.
% This routine is typically called by combining classifier schemes like
% baggingc and boostingc.
%
% See datasets, mappings

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands


function w = traincc(a,w,cclassf)
if ~isa(cclassf,'mapping')
	error('Combining classifier is unknown mapping')
end
[d,labl,map,k,c,v,par] = mapping(cclassf);
if iscombiner(cclassf)
	w = feval(map,w);
else
	w = w*(a*w*cclassf);
end
