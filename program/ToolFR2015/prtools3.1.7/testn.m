%TESTN Error estimate of discriminant for normal distribution.
% 
% 	e = testn(W,U,G,n)
% 
% n normally distributed data vectors with means, labels and prior 
% probabilities defined by the dataset U (size [c,k]) and covariance 
% matrices G (size [k,k,c]) are generated with the specified labels 
% and are tested against the discriminant W. The fraction of  
% incorrectly classified data vectors is returned. If W is a linear 
% discriminant and n is not specified the error is computed 
% analytically. Defaults: n = 10000, G = identity, U = origin.
% 
% See also mappings, datasets, qdc, nbayesc, testd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function e = testn(w,U,G,m)
[v,lablist,type,k] = mapping(w);
if nargin < 4, m = 10000; end
if nargin < 3, G = eye(k); end
if nargin < 2
	u = zeros(1,k); 
else
	[nlab,lablist,c,k,c,p] = dataset(U);
	u = +U;
end

		% check for analytical case

if length(size(G)) == 2
	g = G;
	for j=2:c
		G = cat(3,G,g);
	end
end
if nargin < 4 & strcmp(type,'affine')
	e = 0;
	for j=1:c
		q = real(sqrt(v(1:k)*G(:,:,j)*v(1:k)'));
		J = find(nlab==j);
		if length(J)~=1
			error('Wrong labels assigned')
		end
		d = (2*j-3)*(v(1:k)*u(J,:)'+v(k+1));
		if q == 0
			if d>=0, e=e+p(j); end
		else
			e = e+p(j)*(erf(d/(q*sqrt(2)))/2 + 0.5);
		end
	end
else		% generate data

	a = gauss(m,U,G); 
	e = testd(w,a);
end
return

