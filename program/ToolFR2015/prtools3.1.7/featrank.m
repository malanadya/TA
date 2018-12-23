%FEATRANK Feature ranking on individual performance
% 
% 	[I,F] = featrank(A,crit,T)
% 
% Feature ranking based on the training dataset A. crit determines  
% the criterion used by the feature evaluation routine feateval. If 
% the dataset T is given, it is  used as test set for feateval. In I 
% the features are returned in decreasing performance. In F the 
% corresponding values of feateval are given. Default: crit='NN'.
% 
% See also mappings, datasets, feateval, featselm, featselo, 
% featselb, featself, featselp

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [I,F] = featrank(a,crit,t)
[nlaba,lablista,m,k,c] = dataset(a);
F = zeros(1,k);
if nargin < 3, t = [];; end
if nargin < 2, crit = 'NN'; end

if ~isempty(t)
	[nlabt,lablistt,m,kt,c] = dataset(t);
	if k ~= kt
		error('Feature sizes do not match');
	end
end

for j = 1:k
	if isempty(t)
		F(j) = -feateval(a(:,j),crit);
	else
		F(j) = -feateval(a(:,j),crit,t(:,j));
	end
end
[F,I] = sort(F); F = -F;
return
	
