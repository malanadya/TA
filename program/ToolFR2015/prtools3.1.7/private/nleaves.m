%NLEAVES Computes the number of leaves in a decision tree
% 
% 	number = nleaves(tree,num)
% 
% This procedure counts the number of leaves in a (sub)tree of the 
% tree by using num. If num is omitted, the root is taken (num = 1).
% 
% This is a utility used by maketree. 

% Guido te Brake, TWI/SSOR, TU Delft
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function number = nleaves(tree,num)
if nargin < 2, num = 1; end
if tree(num,3) == 0
 number = 1 ;
else
 number = nleaves(tree,tree(num,3)) + nleaves(tree,tree(num,4));
end
return
