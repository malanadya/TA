%CLEVALF Classifier evaluation (feature size curve)
% 
% 	[e,s] = clevalf(classf,A,featsizes,learnsize,n,T,print)
% 
% Generates at random for all feature sizes stored in featsizes
% training sets of the given learnsize out of the dataset A.
% These are used for training the untrained classifier classf.
% The result is tested by the test dataset T, or, if not
% given, by all unused objects in A. This is  repeated n times.
% If learnsize is not given or empty, the training set is bootstrapped.
% Default featsizes: all feature sizes.
% The mean erors are stored in e. The observed standard deviations
% are stored in s.
% 
% This function uses the rand random generator and thereby 
% reproduces if its seed is reset.
% 
% See also cleval, clevalb, testd, mappings, datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [err,sd] = clevalf(classf,a,featsizes,learnsize,n,T,print)
[m,k] = size(a);
if nargin < 7, print = 0; end;
if nargin < 6, T = []; end
if nargin < 5, n = 1; end;
if nargin < 4, learnsize = []; end
if nargin < 3 | isempty(featsizes), featsizes = [1:k]; end
if ~isa(classf,'mapping'), error('First parameter should be mapping'); end
e1 = zeros(n,length(featsizes));
s = rand('seed');
for i = 1:n
	[b,T] = gendat(a,learnsize);
	for j=1:length(featsizes)
		f = featsizes(j);
		e1(i,j) = b(:,1:f)*classf*T(:,1:f)*testd;
		if print, fprintf('.'); end
	end
end
if print, fprintf('\n'); end 
err = mean(e1,1);
if n == 1
	sd = zeros(size(err));
else
	sd = std(e1);
end
return
