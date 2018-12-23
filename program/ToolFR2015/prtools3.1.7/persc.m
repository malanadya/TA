%PERSC Linear classifier by non-linear perceptron 
% 
% 	[W1,W2] = persc(A,n,step,target,W)
% 
% Finds the linear discriminant function W1 (a mapping) by n cycles 
% of the data through the non-linear (sigmoidal) perceptron with 
% stepsize step and targets (1-target, target). A is the training 
% dataset. A linear classifier W may be supplied for initialisation. 
% Batch training is used. The best set of weights according to the 
% resubstitution error (pocket algorithm) is returned in W2. 
% Defaults: W = Nearest Mean, target = 0.1, step = 0.1, n = 50
% 
% See also mappings, datasets, perlc, ldc, fisherc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl 
% Faculty of Applied Physics, Delft University of Technology 
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [w1,w2] = persc(a,n,step,target,WM)
if nargin < 2, n = 50; end
if nargin < 3, step = 0.1; end
if nargin < 4, target = 0.1; end
if nargin < 1 | isempty(a)
	if nargin < 5
		w1 = mapping('persc',{n,step,target});
	else
		w1 = mapping('persc',{n,step,target,WM});
	end
	return
end
if nargin < 5, WM = nmc(a); end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
if c > 2
	if nargin == 5,
		error('Classifier initialisation not supported in multi-class case');
	end
	w1 = []; w2 = [];
	for i=1:c
		mlab = 2 - (nlab == i);
		aa = dataset(a,mlab);
		[W1i,W2i] = persc(aa,n,step,target);
		w1 = [w1,mapping(W1i,lablist(i,:))];
		w2 = [w2,mapping(W2i,lablist(i,:))];
	end
	
	return
end

emin = testd(a*WM);
V = scalem(a,'variance');
a = a*V;
v = double(V);
u = v{1}; s = v{2};
W = double(WM);
W = [W(1:k)./s';u*W(1:k)+W(k+1)];
W = W /sqrt(W'*W);
Wmin = W;
t = (1-target) * ones(m,1);
x = [+a,ones(m,1)];
J2 = find(nlab==2);
x(J2,:) = -x(J2,:);
er = zeros(2,n);
for i=1:n
	d = x * W;
	e = sum(d<0)/m;
	if e < emin, Wmin = W;
		emin = e;
	end 
	f = 1./(1+exp(-d));
	z = ((t - f) .* (f - f.*f))'* x;
	W = W + step * z';
end 
w1 = mapping('affine',W,lablist,k,1,1,imheight);
w2 = mapping('affine',Wmin,lablist,k,1,1,imheight);
w1 = V*cnormc(w1,a);
w2 = V*cnormc(w2,a);
return

