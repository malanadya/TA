%GENDATB Generation of banana shaped classes
% 
%    A = gendatb(na,nb,s)
% 
% Generation of two banana shaped classes, na vectors for class a 
% and nb vectors for class b. The data is uniformly distributed 
% along the bananas and is superimposed with a normal distribution 
% with standard deviation s in all directions. Defaults: s = 1, nb = 
% na.
% 
% See also datasets

% Copyright: A. Hoekstra, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = gendatb(na,nb,s)
if nargin < 3, s = 1; end
if nargin < 2, nb = na; end

r = 5;
domaina = 0.125*pi + rand(1,na)*1.25*pi;
a   = [r*sin(domaina') r*cos(domaina')] + randn(na,2)*s;

domainb = 0.375*pi - rand(1,nb)*1.25*pi;
a   = [a; [r*sin(domainb') r*cos(domainb')] + randn(nb,2)*s + ones(nb,1)*[-0.75*r -0.75*r]];
lab = genlab([na, nb], ['A'; 'B']);
a = dataset(a,lab);
return
