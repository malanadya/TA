%MCLASSC Computation of multi-class classifier from 2-class discriminants
%
%	W = mclassc(A,classf)
%
% The untrained classifier classf is called to compute c classifiers
% between each of the c classes in the dataset A and the remaining
% c-1 classes. The result is stored in the combined classifier W.
%
% See also datasets, mappings

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = mclassc(a,classf);
if nargin < 2 | ~isa(classf,'mapping') | ~isuntrained(classf)
	error('Second parameter should be untrained mapping')
end
if isempty(a)
	w = mapping('mclassc',classf);
	return
end

[nlab,lablist,m,k,c] = dataset(a);
if c == 1
	error('Dataset should contain more than one class')
end
if c == 2
	w = a*classf;
	return
end

w = [];
for i=1:c
	mlab = 2 - (nlab == i); 
	v = dataset(a,mlab)*classf;
	w = [w,mapping(v,lablist(i,:))];
end
