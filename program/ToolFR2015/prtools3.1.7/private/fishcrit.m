%FISHCRIT Fisher's Criterion and its best feature split 
% 
% 	[f,j,t] = fishcrit(A,nlabels)
% 
% Computes the value of the Fisher's criterion f for all features 
% over the dataset A with given numeric labels. Two classes only. j 
% is the optimum feature, t its threshold. This is a lowlevel 
% routine called for constructing decision trees.

% Copyright R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [f,j,t] = fishcrit(a,nlab)
[m,k] = size(a);
c = max(nlab);
if c > 2
	error('Not more than 2 classes allowed for Fisher Criterion')
end
J1 = find(nlab==1);
J2 = find(nlab==2);
u = (mean(a(J1,:),1) - mean(a(J2,:),1)).^2;
s = std(a(J1,:),0,1).^2 + std(a(J2,:),0,1).^2 + realmin;
f = u ./ s;
[ff,j] = max(f);
m1 = mean(a(J1,j),1);
m2 = mean(a(J2,j),1);
w1 = m1 - m2; w2 = (m1*m1-m2*m2)/2;
if abs(w1) < eps
 t = (max(a(J1,j),[],1) + minc(a(J2,j),[],1)) / 2;
else
 t = w2/w1;
end
