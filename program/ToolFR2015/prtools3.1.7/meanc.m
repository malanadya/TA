%MEANC Averaging combining classifier
% 
% 	W = meanc(V)
% 	W = V*meanc
% 
% If V = [V1,V2,V3, ... ] is a set of classifiers trained on the 
% same classes and W is the mean combiner: it selects the class with 
% the mean of the outputs of the input classifiers. This might also 
% be used as A*[V1,V2,V3]*meanc in which A is a dataset to be 
% classified.
% 
% If it is desired to operate on posterior probabilities then the 
% input classifiers should be extended like V1 = classc(V1).
%
% If all input classifiers are k to 1 affine mappings, their
% coefficients are averaged.
% 
% See also mappings, datasets, maxc, prodc, minc, majorc, medianc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function v = meanc(a)
if nargin == 0
	v = mapping('meanc','combiner');
elseif nargin == 1 & isa(a,'mapping')
	[d,lablist,type,k,c] = mapping(a);
	[nclass,classlist] = renumlab(lablist);
	if ~strcmp(type,'parallel') &  ~strcmp(type,'stacked')
		v = a*mapping('meanc',NaN,classlist,c,size(classlist,1));
		return
	end
	ld = length(d); typd = zeros(1,ld);
	ww = zeros(k+1,ld);
					% Average linear affine mappings
	for i=1:ld
		ti = strcmp(getmap(d{i}),'affine') & ~isclassifier(d{i});
		ti = ti & size(d{i},2) == 2 & ~isclassifier(a);
		if ti, ww(:,i) = +d{i}; else break; end
		typd(i) = ti;
	end
	if all(typd)
		v = mapping('affine',mean(ww,2),classlist,k,1);
	else
		v = a*mapping('meanc',NaN,classlist,c,size(classlist,1));
	end
else
	[nlab,lablist,m,ka,ca,prob,featlist,imheight] = dataset(a);
	[nclass,classlist] = renumlab(featlist);
	c = size(classlist,1);
	v = dataset(zeros(m,c),getlab(a),classlist,prob,lablist,imheight);
	for j=1:c
		J = find(nclass==j);
		v(:,j) = mean(a(:,J),2);
	end
end
