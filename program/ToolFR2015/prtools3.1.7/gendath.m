%GENDATH Generation of Higleyman classes
% 
% 	A = gendath(na,nb)
% 
% Generation of dataset A according to Highleyman. na vectors for 
% classs A are generated and  nb vectors for class B. Default nb = 
% na.  Highleyman classes are defined by N([1 1],[1 0; 0 0.25]) for 
% class A and N([2 0],[0.01 0; 0 4]) for class B.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function A = gendath(na,nb)
if nargin == 1, nb = na; end
GA = [1 0; 0 0.25];    GB = [0.01 0; 0 4];
G = cat(3,GA,GB);
U = dataset([1 1; 2 0],[1 2]');
A = gauss([na nb],U,G);
return
