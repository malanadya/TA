%FEATSELI Individual feature selection
% 
% 	[W,R] = featseli(A,crit,k,T)
% 
% Individual selection of k features using the dataset A. crit sets 
% the criterion used by the feature evaluation routine feateval. If 
% the data set T is given, it is used as test set for feateval. For 
% k=0 all features are selected, but reordered according to the 
% criterion. The result W can be used for selecting features by B*W.  
% Defaults: crit='NN', k=0. In R the search is step by step 
% reported:
% 
% 	R(:,1) : number of features
% 	R(:,2) : criterion value
% 	R(:,3) : added / deleted feature
% 
% See also mappings, datasets, feateval, featselm, featselb, 
% featselo, featselp, featself

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,R] = featseli(A,crit,ksel,T)
if nargin < 2, crit = 'NN'; end
if nargin < 3, ksel = 0; end
if nargin < 4, T = []; end

if nargin == 0 | isempty(A)
	W = mapping('featseli',{crit,ksel,T});
    return
end

[nlaba,lablist,m,k,c,prob,featlist] = dataset(A);
if ksel == 0, ksel = k; end
    
if ~isempty(T)
	[mt,kt] = size(T);
	if kt ~= k
		error('Data sizes do not match')
	end
end

C = zeros(k,1);
for j = 1:k
	if isempty(T)
		C(j) = feateval(A(:,j),crit);
	else
		C(j) = feateval(A(:,j),crit,T(:,j));
	end
end
[cc,J] = sort(-C);
R = [[1:k]' -cc J];
J = J(1:ksel)';
W = mapping('featsel',J,featlist(J,:),k,ksel);
return

