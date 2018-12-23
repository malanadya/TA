%MAXCRIT Maximum entropy criterion for best feature split.
% 
% 	[f,j,t] = maxcrit(A,nlabels)
% 
% Computes the value of the maximum purity f for all features over 
% the data set A given its numeric labels. The criterion used is the 
% gini value at all class minimum and maximum values for all 
% features [1]. j is the optimum feature, t its threshold. This is a 
% low level routine called for constructing decision trees.
% 
% [1] L. Breiman, J.H. Friedman, R.A. Olshen, and C.J. Stone, 
% Classification and regression trees, Wadsworth, California, 1984. 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl 
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [f,j,t] = maxcrit(a,nlab)
[m,k] = size(a);
c = max(nlab);
T = zeros(2*c,k); R = zeros(2*c,k);
for j = 1:c
	L = (nlab == j);
	if sum(L) == 0
		T([2*j-1:2*j],:) = zeros(2,k);
		R([2*j-1:2*j],:) = zeros(2,k);
	else
		T(2*j-1,:) = min(a(L,:),[],1);
		R(2*j-1,:) = sum(a < ones(m,1)*T(2*j-1,:),1);
		T(2*j,:) = max(a(L,:),[],1);
		R(2*j,:) = sum(a > ones(m,1)*T(2*j,:),1);
	end
end
G = R .* (m-R);
[gmax,tmax] = max(G,[],1);
[f,j] = max(gmax);
Tmax = tmax(j);
if Tmax ~= 2*floor(Tmax/2)
	t = (T(Tmax,j) + max(a(find(a(:,j) < T(Tmax,j)),j)))/2;
else
	t = (T(Tmax,j) + min(a(find(a(:,j) > T(Tmax,j)),j)))/2;
end
return
