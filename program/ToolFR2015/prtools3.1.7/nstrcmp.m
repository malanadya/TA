%NSTRCMP Counts the number of different strings in two string sets
% 
% 	[N,C] = nstrcmp(S1,S2)
% 
% C is a 0/1 vector pointing to all different/equal strings. N is 
% the number of zeros in C. 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [N,C] = NSTRCMP(S1,S2)
[m,k] = size(S1);
[n,l] = size(S2);
if m~=n | k~=l
	error('Data sizes do not match')
end
C = all(S1'==S2',1)';
N = m - sum(C);
return
