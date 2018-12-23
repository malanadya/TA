%PERLC Linear classifier by linear perceptron 
% 
% 	W1 = perlc(A,n,step,w)
% 
% Finds the linear discriminant function W1 (a mapping) by n cycles 
% of the data through the linear perceptron with stepsize step. A is 
% the training dataset. A linear classifier W may be supplied for 
% initialisation. Batch training is used. The best set of weights 
% according to the resubstitution error (pocket algorithm) is 
% returned in W2. Defaults: W = Nearest Mean, step = 0.1, n = 50
% 
% See also mappings, datasets, persc, ldc, fisherc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl 
% Faculty of Applied Physics, Delft University of Technology 
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = perlc(a,n,step,WM)
if nargin < 2, n = 50; end
if nargin < 3, step = 0.1; end
if nargin < 1 | isempty(a)
	if nargin < 4
		W = mapping('perlc',{n,step});
	else
		W = mapping('perlc',{n,step,WM});
	end
	return
end
if nargin < 4, WM = nmc(a); end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
if c > 2
	if nargin == 5,
		error('Classifier initialisation not supported in multi-class case');
	end
	W = [];
	for i=1:c
		mlab = 2 - (nlab == i); 
		aa = dataset(a,mlab);
		w = perlc(aa,n,step);
		W = [W,mapping(w,lablist(i,:))];
	end
	
	return
end

emin = testd(WM,a);
V = scalem(a,'variance');
a = a*V;
v = double(V);
u = v{1}; s = v{2};
W = double(WM);
W = [W(1:k)./s';u*W(1:k)+W(k+1)];
W = W/sqrt(W'*W);
Wmin = W;
x = [+a,ones(m,1)];
J2 = find(nlab==2);
x(J2,:) = -x(J2,:);
y = zeros(m,1);
for i=1:m
	y(i) = x(i,:)*x(i,:)';
end
er = zeros(1,n);
for i=1:n
	d = x * W;
	e = sum(d<0)/m;
	if e < emin, Wmin = W;
		emin = e;
	end
	z = sqrt(abs(y./(y-d.^2)))'*x;
	W = W + step * z';
end 

W = mapping('affine',W,lablist,k,1,1,imheight);
W = V*cnormc(W,a);
return

