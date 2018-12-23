%CONFMAT Construct confusion matrix
% 
% 	[C,ne,lablist] = confmat(lab1,lab2)
% 
% Constructs a confusion matrix C between two sets of labels lab1 
% (rows in C) and lab2 (columns in C). The order of the rows and 
% columns is returned in lablist. ne is the total number of errors 
% (sum of non-diagonal elements in C).

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [C,ne,lablist] = confmat(lab1,lab2)
[nlab1,nlab2,lablist] = renumlab(lab1,lab2);
n = max([nlab1;nlab2]);
C = zeros(n,n);
for i=1:n
	K = find(nlab1 == i);
	if isempty(K)
		C(i,:) = zeros(1,n);
	else
		for j=1:n
			C(i,j) = length(find(nlab2(K)==j));
		end
	end
end
ne = sum(sum(C)) - sum(diag(C));
return
