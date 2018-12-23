%NORMALM Estimate normal densities
%
%	W = NORMALM(A,TYPE)
%
%	D = B*W
%
% For each of the classes in the dataset A a normal distribution
% is estimated. The result is stored as a K*C mapping in W, in which
% K is the dimensionality of the input space and C is the number
% of classes.
%
% TYPE can be used to set some assumptions on the covariance matrices.
% It can be 'unequal' (default), 'equal' and 'uncorrelated'.
%
% The mapping W may be applied to a new K-dimensional dataset B,
% resulting in a C-dimensional dataset D. The values in D are not
% properly scaled.
%
% See also datasets, mappings, parzenm, qdc, normal_map

function w = normalm(a,w)
if nargin < 2, w = 'unequal'; end
if nargin < 1 | isempty(a)
	w = mapping(mfilename,w);
	return
end
if ~isa(w,'mapping')
	switch w

	case 'unequal'
		w = qdc(a);
	case 'equal'
		w = ldc(a);
	case 'uncorrelated'
		w = udc(a);
	otherwise
		error('Unknown option for type')
	end
	w = set(w,'m',mfilename);
elseif isa(w,'mapping')
	w = normal_map(a,w);
else
	error('Illegal call')
end

function F = normal_map(A,W)

[w,classlist,type,k,c,v,par] = mapping(W);
deg = ndims(w{2})-1;
U = +w{1}; G = w{2}; p = w{3};

[m,ka] = size(A);
if ka ~= k, error('Wrong feature size'); end

F = zeros(m,c);
if deg == 1
	H = G;
	if rank(H) < size(H,1)
		E = real(pinv(H));
	else
		E = real(inv(H));
	end
end
Cmax = -inf;
for i=1:c
	X = +A - ones(m,1)*U(i,:);
	if deg == 2
		H = G(:,:,i);
		if rank(H) < size(H,1)
			E = real(pinv(H));
		else
			E = real(inv(H));
		end
	end
	C = log(p(i)) - 0.5*(sum(log(real(eig(H))+realmin)) + log(2*pi));
	F(:,i) = (C - sum(X'.*(E*X'),1).*0.5)'; 
end

F = exp(F) + realmin;
[nlab,lablist,m,k,c,p,classlista,imheight] = dataset(A);
if imheight > 0, imheight = 0; end
F = dataset(F,getlab(A),classlist,p,lablist,imheight);
return
