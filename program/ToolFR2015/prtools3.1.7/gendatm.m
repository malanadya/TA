%GENDATM Generation of multi-class data
% 
% 	A = gendatm(n)
% 
% Generation of n samples for each of 6 classes of 2 dimensionally 
% distributed data vectors.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function A = gendatm(n)
a = gendath(n);
b = gendatc(n)./5;
c = gendatb(n)./5;
d = gendatl(n)./5;
A = double([a; b+5; c + ones(2*n,1)*[5,0]; d + ones(2*n,1)*[0,5]]);
lab = genlab(n*ones(1,8),['aaa';'bbb';'ccc';'ddd';'eee';'fff';'ggg';'hhh']);
A = dataset(A,lab);
