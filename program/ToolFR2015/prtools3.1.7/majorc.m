%MAJORC Majority combining classifier
% 
% 	W = majorc(V)
%	W = v*majorc
% 
% If V = [V1,V2,V3,...] is a stacked set of classifiers trained for
% the same classes and W is the majority combiner: it selects the 
% class with the majority of the outputs of the input classifiers. 
% This might also be used as A*[V1,V2,V3]*majorc in which A is a 
% dataset to be classified.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function v = majorc(a,w)
if nargin == 0
	v = mapping('majorc','combiner');
elseif nargin == 1 & isa(a,'mapping')
	[nclass,classlist] = renumlab(getfeat(a));
	v = mapping('majorc',a,classlist,size(a,1),size(classlist,1));
elseif nargin == 1 & isa(a,'dataset')
	[nlab,lablist,m,ka,ca,prob,featlist] = dataset(a);
	[nf,fl] = renumlab(featlist);
	c = max(nf);
	n = floor(length(nf)/c);
	mlab = zeros(m,n);
	for j=1:n
		J = [(j-1)*c+1:j*c];
		labels = classd(a(:,J));
		[nl,nlab,ll] = renumlab(lablist,labels);
		mlab(:,j) = nlab;
	end
	v = dataset(zeros(m,c),getlab(a),lablist,prob,lablist);
	for j=1:c
		v(:,j) = (sum(mlab==j,2)+1)/(n+c);
	end
	v = invsig(v);
else	% more general, undocumented possibility: majorc(a,w)
		% takes care of a parallel combination of classifiers
		% with possibly different numbers of class outputs
	[nlab,lablist,m,ka,ca,prob,featlist] = dataset(a);
	[w,classlist,map] = mapping(w);
	if strcmp(map,'majorc')
		[w,classlist,map] = mapping(w);
	end
	par = strcmp(map,'parallel');
	[nc,classlist] = renumlab(classlist);
	c = size(classlist,1);
	n = length(w);
	mlab = zeros(m,n); 
	ka1 = 0;
	for j = 1:n
		if par
			ka2 = ka1 + size(w{j},1);
			labels = classd(a(:,ka1+1:ka2)*w{j});
			ka1 = ka2;
		else
			labels = classd(a*w{j});
		end
		[nl,nlab,ll] = renumlab(classlist,labels);
		mlab(:,j) = nlab;
	end
	v = dataset(zeros(m,c),getlab(a),classlist,prob,lablist);
	for j=1:c
		v(:,j) = (sum(mlab==j,2)+1)/(n+c);
	end
	v = invsig(v);
end
