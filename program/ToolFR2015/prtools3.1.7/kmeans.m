%KMEANS k-means clustering
% 
% 	[labels,A] = kmeans(A,k)
% 
% k-means clustering of data vectors in A. labels is a vector with 
% cluster labels (1, .. , k) for each vector. Default: k = 2, n = 1.
% 
% See also datasets, hclust, kcentres, modeseek

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [labs,a] = kmeans(a,kmax,classf)
if nargin < 2, kmax = 2; end
if nargin < 3, classf = nmc; end
m = size(a,1);
a = dataset(a,ones(m,1));
if m > 100
	b = +gendat(a,100); 
	d = +distm(b);
	labs = kcentres(d,kmax);
	w = nmc(dataset(b,labs));
	labs = classd(a*w);
else
	d = +distm(a);
	labs = kcentres(d,kmax);
	w = nmc(dataset(a,labs));
	labs = classd(a*w);
end
labt = zeros(m,1);
while any(labt ~= labs)
	labt = labs;
	a = dataset(a,labs);
	w = a * classf;
	labs = a * w * classd;
end


