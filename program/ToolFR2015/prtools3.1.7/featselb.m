%FEATSELB Backward feature selection
% 
% 	[W,R] = featselb(A,crit,k,T)
% 
% Backward selection of k features using the dataset A. crit sets 
% the criterion used by the feature evaluation routine feateval. If 
% the data set T is given, it is used as test set for feateval. For 
% k=0 the optimal feature set (maximum value of feateval) is 
% returned. The result W can be used for selecting features by B*W.  
% In this case features are ranked optimally. Defaults: crit='NN', 
% k=0.
% 
% See also mappings, datasets, feateval, featselm, featself, 
% featselo, featselp, featseli

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,R] = featselb(A,crit,ksel,T)
if nargin < 2, crit = 'NN'; end
if nargin < 3, ksel = 0; end
if nargin < 4, T = []; end

if nargin == 0 | isempty(A)
	W = mapping('featselb',{crit,ksel,T});
    return
end

[nlaba,lablist,m,k,c,prob,featlist] = dataset(A);

if ~isempty(T)
	[mt,kt] = size(T);
	if kt ~= k
		error('Data sizes do not match')
	end
end

Cmax = feateval2(A,crit,T);
I = [1:k];
Iopt = I;
R = [k,Cmax,0];
Jopt = [];
while length(I) > 1
	C = zeros(1,length(I));
	for j = 1:length(I)
		J = I; J(j) = [];
		if isempty(T)
			C(j) = feateval(A(:,J),crit);
		else
			C(j) = feateval2(A(:,J),crit,T(:,J));
		end
		if C(j) >= Cmax
			Cmax = C(j);
			Iopt = J;
		end
	end
	[mx,j] = max(C);
	r = [length(I)-1,mx,-I(j)];
	%disp(r)
	R = [R; r];
	Jopt = [I(j) Jopt];
	I(j) = [];
	if length(I) == ksel
		W = mapping('featsel',I,featlist(I,:),k,length(I));
		return
	end
end
Jopt = [I(1) Jopt];
if ksel==0 & (length(Iopt) == k), Iopt = Jopt; end % Rank features backward
W = mapping('featsel',Iopt,featlist(Iopt,:),k,length(Iopt));
return

