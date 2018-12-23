%POLYC Polynomial Classification
% 
% 	W = polyc(A,classf,n,s)
% 
% Adds polynomial features to the dataset A and runs the untrained 
% classifier classf. n is the degree of the polynome (default 1). If 
% s == 1 (default 0) all second order combination terms are added as 
% well.
% 
% See also mappings, datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = polyc(a,classf,n,s)
if nargin < 4, s = 0; end
if nargin < 3, n = 1; end
if nargin < 2, classf = 'fisherc'; end
if nargin < 1 | isempty(a)
	W = mapping('polyc',{classf,n,s});
	return
end
[nlab,lablist,m,k,c] = dataset(a);
P = eye(k);
for j = 2:n
	P = [P; j*eye(k)];
end
if s & (k > 1)
	Q = zeros(k*(k-1)/2,k);
	n = 0;
	for j1 = 1:k
		for j2 = j1+1:k
			n = n+1;
			Q(n,j2) = Q(n,j2)+1;
			Q(n,j1) = Q(n,j1)+1;
		end
	end
	P = [P;Q];
end
v = cmapm(k,P);
w = a*v*classf;
W = v*w;
return

