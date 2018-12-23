%MAXC Maximum combining classifier
% 
% 	W = maxc(V)
% 	W = V*maxc
% 
% If V = [V1,V2,V3, ... ] is a set of classifiers trained on the 
% same classes and W is the maximum combiner: it selects the class 
% with the maximum of the outputs of the input classifiers. This 
% might also be used as A*[V1,V2,V3]*maxc in which A is a dataset to 
% be classified. Consequently, if S is a similarity matrix with
% class feature labels (e.g. S = A*proxm(A,'r')) then S*maxc*classd
% is the nearest neighbor classifier.
% 
% If it is desired to operate on posterior probabilities then the 
% input classifiers should be extended like V = v*classc;
% 
% See also mappings, datasets, meanc, prodc, minc, majorc, medianc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function v = maxc(a)
if nargin == 0
	v = mapping('maxc','combiner');
elseif nargin == 1 & isa(a,'mapping')
	[nclass,classlist] = renumlab(getfeat(a));
	v = a*mapping('maxc',NaN,classlist,size(a,2),size(classlist,1));
else
	[nlab,lablist,m,ka,ca,prob,featlist,imheight] = dataset(a);
	[nclass,classlist] = renumlab(featlist);
	c = size(classlist,1);
	v = dataset(zeros(m,c),getlab(a),classlist,prob,lablist,imheight);
	for j=1:c
		J = find(nclass==j);
		v(:,j) = max(a(:,J),[],2);
	end
end
