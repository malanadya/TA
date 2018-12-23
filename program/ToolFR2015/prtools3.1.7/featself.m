%FEATSELF Forward feature selection
% 
% 	[W,R] = featself(A,crit,k,T)
% 
% Forward selection of k features using the dataset A. crit sets the 
% criterion used by the feature evaluation routine feateval. If the 
% data set T is given, it is used as test set for feateval. For k=0 
% the optimal feature set (maximum value of feateval) is returned. 
% The result W can be used for selecting features by B*W.  Defaults: 
% crit='NN', k=0. In R the search is step by step reported:
% 
% 	R(:,1) : number of features
% 	R(:,2) : criterion value
% 	R(:,3) : added / deleted feature
% 
% See also mappings, datasets, feateval, featselm, featselb, 
% featselo, featselp, featseli

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,R] = featself(A,crit,ksel,T)
if nargin < 2, crit = 'NN'; end
if nargin < 3, ksel = 0; end
if nargin < 4, T = []; end

if nargin == 0 | isempty(A)
	W = mapping('featself',{crit,ksel,T});
    return
end

[nlaba,lablist,m,k,c,prob,featlist] = dataset(A);

if ~isempty(T)
	[mt,kt] = size(T);
	if kt ~= k
		error('Data sizes do not match')
	end
end

Cmax = 0;
I = [1:k];
J = [];
R = [];
Iopt = J;
while length(J) < k
	C = zeros(1,length(I));
	for j = 1:length(I)
		L = [J,I(j)];
		if isempty(T)
			C(j) = feateval(A(:,L),crit);
		else
			C(j) = feateval2(A(:,L),crit,T(:,L));
		end
		if C(j) > Cmax
			Cmax = C(j);
			Iopt = L;
		end
	end
	[mx,j] = max(C);
	J = [J,I(j)];
  	I(j) = [];
	r = [length(J),mx,J(end)];
	%disp(r)
	R = [R; r];
	if length(J) == ksel
		W = mapping('featsel',J,featlist(J,:),k,length(J));
		return
	end
end
W = mapping('featsel',Iopt,featlist(Iopt,:),k,length(Iopt));
return

