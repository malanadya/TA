%FEATSELP Pudil's floating feature selection (forward)
% 
% 	[W,R] = featselp(A,crit,k,T)
% 
% Forward floating selection of k features using the dataset A. crit 
% sets the criterion used by the feature evaluation routine 
% feateval. If the data set T is given, it is used as test set for 
% feateval. For k=0 the optimal feature set (maximum value of 
% feateval) is returned. The result W can be used for selecting 
% features by B*W. In R the search is step by step reported:
% 
% 
% 
% 	R(:,1) : number of features
% 	R(:,2) : criterion value
% 	R(:,3) : added / deleted feature
% 
% Defaults: crit='NN', k=0
% 
% See also mappings, datasets, feateval, featselm, featself, 
% featselb, featselo, featseli

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,R] = featselp(A,crit,ksel,T)
if nargin < 2, crit = 'NN'; end
if nargin < 3, ksel = 0; end
if nargin < 4, T = []; end

if nargin == 0 | isempty(A)
	W = mapping('featselp',{crit,ksel,T});
    return
end

[nlaba,lablist,m,k,c,prob,featlist] = dataset(A);

if ksel == 0, peak = 1; ksel = k; else peak = 0; end

if ~isempty(T)
	[mt,kt] = size(T);
	if kt ~= k
		error('Data sizes do not match')
	end
end

Cmax = 0;
CC = zeros(1,k);
I = [1:k];
J = [];
R = [];
Iopt = J;
n = 0;
while n < k
	C = zeros(1,length(I));
	for j = 1:length(I)
		L = [J,I(j)];
      if isempty(T)
         C(j) = feateval(A(:,L),crit);
		else
			C(j) = feateval(A(:,L),crit,T(:,L));
      end
      if C(j) > Cmax & n < ksel
			nmax = length(L);
			Cmax = C(j);
			Iopt = L;
		end
	end
	[mx,j] = max(C);
	n = n + 1;
	CC(n) = mx;
	J = [J,I(j)];
	I(j) = [];
	r = [n,mx,J(end)];
	R = [R; r];
 	disp(r)
   
	while n > 2
		C = zeros(1,n);
		for j = 1:n
			L = J; L(j) = [];
			if isempty(T)
				C(j) = feateval(A(:,L),crit);
			else
				C(j) = feateval(A(:,L),crit,T(:,L));
			end		
			if ( (C(j) > Cmax) | ((C(j) == Cmax) & (length(L) < nmax))) & (n <= ksel + 1);
				nmax = length(L);
				Cmax = C(j);
				Iopt = L;
			end
		end
		[mx,j] = max(C);
		if mx > CC(n-1) 
			n = n - 1;
			CC(n) = mx;
			I = [I,J(j)];
			J(j) = [];
			r = [n,mx,-I(end)];
			R = [R; r];
 			disp(r)
		else
			break
		end
	end
      
	if n > ksel
		J = Iopt;
		W = mapping('featsel',J,featlist(J,:),k,length(J));
		return
	end
end
W = mapping('featsel',Iopt,featlist(Iopt,:),k,length(Iopt));
return

