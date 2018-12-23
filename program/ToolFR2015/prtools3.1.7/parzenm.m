%PARZENM Estimate Parzen densities
%
%	W = PARZENM(A,H)
%
%	D = B*W
%
% For each of the classes in the dataset A a Parzen distribution
% is estimated. The result is stored as a K*C mapping in W, in which
% K is the dimensionality of the input space and C is the number
% of classes. The desired smoothing parameter(s) should be stored in
% the vector H. Default a ml-optimization is performed.
%
% The mapping W may be applied to a new K-dimensional dataset B,
% resulting in a C-dimensional dataset D. The values in D are not
% properly scaled.
%
% See also datasets, mappings, normalm, parzenc

function w = parzenm(a,h)
if nargin < 2, h = []; end
if nargin < 1 | isempty(a)
	w = mapping(mfilename,h);
	return
end
if ~isa(h,'mapping')
	if isempty(h), h = parzenml(a); end
	w = parzenc(a,h);
	w = set(w,'m',mfilename);
else 
	w = parzen_map(a,h);
end

function F = parzen_map(T,W)
[a,classlist,type,k,c,v,h] = mapping(W);
[nlab,lablist,m,k,c,p] = dataset(a);
p = p(:)';
h = h(:)';
[mt,kt] = size(T);
if kt ~= k, error('Wrong feature size'); end

if length(h) == 1, h = h * ones(1,c); end
if length(h) ~= c
	error('Wrong number of smoothing parameters')
end
maxa = max(max(abs(a)));
a = a/maxa;
T = T/maxa;
h = h/maxa;
if isfeatim(T)
	F = datgauss(T,h);
end
alf=sqrt(2*pi)^k;
[num,n] = prmem(mt,m);
F = ones(mt,c);
for j = 0:num-1
	if j == num-1
		nn = mt - num*n + n;
	else
		nn = n;
	end
	range = [j*n+1:j*n+nn];
	D = +distm(a,T(range,:));
	for i=1:c
		I = find(nlab == i);
		if length(I) > 0
			F(range,i) = mean(exp(-D(I,:)*0.5./(h(i).^2)),1)';
		end
	end
end
F = F.*repmat(p./(alf.*h.^k),mt,1);
%if max(h) ~= min(h)	% avoid this when possible (problems with large k)
%	F = F.*repmat(p./(h.^k),mt,1);
%else
%	F = F.*repmat(p,mt,1);
%end
F = F + realmin;
%F = F ./ (sum(F')'*ones(1,c));
%F = invsig(F);
[nlab,lablist,m,k,c,p] = dataset(T);
F = dataset(F,getlab(T),classlist,p,lablist);
return
