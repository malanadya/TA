%GENDAT Random generation of datasets for training and testing
% 
% 	[A,B,IA,IB] = gendat(X,n)
% 
% Selects at random n(i) vectors out of class i in the dataset X and 
% stores them in A. The remaining vectors are stored in B.
% Classes are ordered using renumlab(getlab(X)). If n is a scalar,
% then n objects are selected for each class. By n < 1 relative sizes
% may be defined with respect to the original class sizes.
% IA and IB are the indices of the objects selected from X for A and B.
% 
% If n is not given or empty, the data set X is bootstrapped and stored
% in A. Not selected samples are stored in B.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [a,b,IA,IB] = gendat(x,n);
[nlab,lablist,m,k,c,prob,featlist] = dataset(x);
if nargin < 2 | isempty(n)
	bootstrap = 1;
else
	bootstrap = 0;
	if length(n) == 1
		n = n*ones(1,c);
	elseif length(n) == c
		;
	else
		error('Vector length of number of objects should equal number of classes')
	end
	if all(n<1)
		n = round(n(:).*classsizes(x));
	end
end
IA = []; IB = [];

for i = 1:c
	J = find(nlab==i);
	mc = length(J);
	if bootstrap
		p = ceil(rand(1,mc)*mc);
		q = [1:mc]; q(p) = [];
	else
		if n(i) > mc
			error('More vectors requested than available');
		end
		p = randperm(mc);
		q = p(n(i)+1:mc);
		p = p(1:n(i));
	end
    IA = [IA; J(p)];
    IB = [IB; J(q)];
end
a = x(IA,:);
b = x(IB,:);
if isa(x,'dataset')
	imheight = getimheight(x);
	if imheight < 0, imheight = 0; end
	a = dataset(a,[],[],[],[],imheight);
	b = dataset(b,[],[],[],[],imheight);
end
return
