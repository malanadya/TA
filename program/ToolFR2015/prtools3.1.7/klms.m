%KLMS Scaled version of klm
% 
% 	[W,alf] = klms(A,n)
% 	[W,n] = klms(A,alf)
% 
% Default n: select all (orthogonalize and scale). The resulting 
% mapping has a unit covariance matrix.
% 
% See also mappings, datasets, klm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [w,q] = klms(a,n)
if nargin < 2, n = []; end
if nargin < 1 | isempty(a)
   w = mapping('klms',n); return
end
 
[w,q] = klm(a,n);
b = a*w;
w = w*scalem(b,'c-variance');
w = set(w,'p',getimheight(a));
return
