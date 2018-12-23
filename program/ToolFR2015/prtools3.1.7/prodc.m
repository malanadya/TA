%PRODC Product combining classifier
% 
% 	W = prodc(V)
% 	W = V*prodc
% 
% If V = [V1,V2,V3, ... ] is a set of classifiers trained on the 
% same classes and W is the product combiner: it selects the class 
% with the product of the outputs of the input classifiers. This 
% might also be used as A*[V1,V2,V3]*prodc in which A is a dataset 
% to be classified.
% 
% If it is desired to operate on posterior probabilities then the 
% input classifiers should be extended like V1 = classc(V1).
% 
% See also mappings, datasets, meanc, maxc, minc, majorc, medianc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function v = prodc(a)
if nargin == 0
	v = mapping('prodc','combiner');
elseif nargin == 1 & isa(a,'mapping')
	[nclass,classlist] = renumlab(getfeat(a));
	v = a*mapping('prodc',NaN,classlist,size(a,2),size(classlist,1));
else
	[nlab,lablist,m,ka,ca,prob,featlist,imheight] = dataset(a); 
	[nclass,classlist] = renumlab(featlist);
	c = size(classlist,1);
	v = dataset(zeros(m,c),getlab(a),classlist,prob,lablist,imheight);
	for j=1:c
		J = find(nclass==j);
		v(:,j) = exp(mean(log(a(:,J)+1e-100),2));
	end
end
