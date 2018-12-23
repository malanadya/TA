%CROSSVAL Crossvalidation, classifier error and stability
% 
% 	[e,s] = crossval(classf,A,n)
% 
% Crossvalidation estimation of the error and the instability of the 
% classifier classf using the dataset A. The set is randomly 
% permutated. n objects are left out, the classifier is trained and 
% these objects are used for estimating the instability and the 
% error. This is rotated over the entire learning set.
% 
% The instability is defined as the average fraction of  
% classification differences between the classifier based on the 
% entire training set and a disturbed version (e.g. a  leave-one-out 
% version of the classifier).
% 
% Default: n = 1 (leave-one-out method).
% 
% See also mappings, datasets, testd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [e,s] = crossval(classf,a,n)
if nargin < 3, n = 1; end
[m,k] = size(a);
lab = getlab(a);
%[nlab,lablist,m,k,c] = dataset(a);
if n > m | n < 1
	error('Wrong size of rotation set')
end
J = randperm(m);
lab1 = a*(a*classf)*classd;
e = 0;
s = 0;
iter = ceil(m/n);
for i = 1:iter
	OUT = (i-1)*n+1:i*n; JOUT=J(OUT);
	JIN = J; JIN(OUT) = [];
	w = a(JIN,:)*classf;
	labout = a(JOUT,:)*w*classd;
	e = e + nstrcmp(labout,lab(JOUT,:));
	s = s + nstrcmp(labout,lab1(JOUT,:));
end
e = e / m;
s = s / m;
