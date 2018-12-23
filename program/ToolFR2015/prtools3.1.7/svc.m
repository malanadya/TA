%SVC Support Vector Classifier
% 
% 	[W,J] = svc(A,type,par,C)
% 
% Optimizes a support vector classifier for the dataset A by 
% quadratic programming. The classifier can be of one of the types 
% as defined by proxm. Default is linear (type = 'p', par = 1). In J 
% the indices of the support objects are returned. C < 1 allows for 
% more class overlap. Default C = 1.
% 
% See also datasets, mapppings, proxm

% Copyright: D. de Ridder, D. Tax, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands
  
function [W,J] = svc(a,type,par,C)
if nargin < 4 | isempty(C), C = 1; end
if nargin < 3 | isempty(par), par = 1; end
if nargin < 2 | isempty(type), type = 'p'; end
if nargin < 1 | isempty(a)
	W = mapping('svc',{type,par,C});
	return
end
	
[nlab,lablist,m,k,c] = dataset(a);

if c > 2
	W = [];
	J = zeros(1,m);
	for i=1:c
		mlab = 2 - (nlab == i);
		aa = dataset(a,mlab);
		[v,j] = svc(aa,type,par,C);
		W = [W,mapping(v,lablist(i,:))];
		J(j) = ones(1,length(j));
	end
	J = find(J);
else
	y = 3 - 2*nlab;
	u = mean(a);
	a = a -ones(m,1)*u;
	K = a*proxm(a,type,par);
	[v,J] = svo(+K,y,C);
	if isnan(v)
		v = double(fisherc(K));
		J = [1:m];
	end
	W = mapping('support-vector',{u,a(J,:),v},lablist,k,1,1,{type,par});
	W = cnormc(W,a);
end
return


