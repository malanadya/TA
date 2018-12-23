%RNNC Random neural net classifier
% 
% 	W = rnnc(A,n,s)
% 
% W is a feed-dorward neural net with one hidden layer of n neurons 
% The input layer is random, the output layer is trained by the 
% dataset A.
% 
% See also datasets, mappings, lmnc, bpxnc, rbnc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = rnnc(a,n,s)
if nargin < 3, s = 1; end
if nargin < 2, n = 10; end
if nargin < 1 | isempty(a)
	w = mapping('rnnc',{n,s});
	return
end
[m,k] = size(a);
v = scalem(a,'variance');
v = v*cmapm(randn(n,k)*s,'rot');
v = v*cmapm(randn(1,n)*s,'shift');
vv = +v;
w = v*sigm;
u = fisherc(a*w);
uu = +u;
c = size(u,2);
w = mapping('neurnet',[vv(:); uu(:)]',getfeat(u),k,c,1,[k n c]);
%w = w*kljlc(a*w,floor(m/3));
