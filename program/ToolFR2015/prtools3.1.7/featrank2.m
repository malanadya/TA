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

function [I,F] = featrank2(a,crit,kk,t)
[nlaba,lablista,m,k,c] = dataset(a);
F = zeros(1,k);



for j = 1:k
		F(j) = -feateval2(a(:,j),crit,kk);
end
[F,I] = sort(F); F = -F;
return
	
