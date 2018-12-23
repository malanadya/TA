%CNORMC Classifier normalisation for good posteriori probabilities
% 
% 	W = cnormc(W,A)
% 
% The mapping W is scaled according to the dataset A  in such a 
% way that A*W*classc represents as good as possible the posteriori 
% probabilities. This is done by a multiplicative scaling on the 
% classifier outputs such that the sigmoid outputs added by classc 
% yield a maximum likelihood result on A. This does not influence 
% the decision boundary itself.
% 
% See also datasets, mappings, loglc 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = cnormc(W,A)
if isempty(W)
	W = mapping('cnormc','combiner',A);
	return
end
if ~isa(W,'mapping')
	error('First argument should be a mapping')
end
[nlab,lablist,m,k,c,p] = dataset(A);
classbit = isclassifier(W);
W = setclass(W,0);%controlli
x = double(A*W);%x sono le similarità, il numero di colonne è pari alle classi
if c == 2 & size(x,2) == 1, x = [x -x]; end
	% alf is used for an automatic regularization, important for
	% non-overlapping classes
alf = 1e-7;
v = 1e-10; L = -inf; Lnew = -realmax;
if isa(nlab,'dataset')
	xx = +sum(x.*nlab,2);
	while abs(Lnew - L) > 1e-6;
		pax = sigm(xx*v); pbx = 1 - pax; vv= v + 1;
		L = Lnew; Lnew = mean(log(pax+realmin))-alf*log(vv);
		v = (pbx' * xx - alf*m/vv) / ...
			((xx.*pax)'*(xx.*pbx) - m*alf/(vv*vv) +realmin) + v;
	end
else
	xx = x(m*nlab-m+[1:m]');
	while abs(Lnew - L) > 1e-6;
		pax = sigm(xx*v); pbx = 1 - pax; vv= v + 1;
		L = Lnew; Lnew = mean(p(nlab).*log(pax+realmin))-alf*log(vv);
		v = ((p(nlab).*pbx)' * xx - alf*m/vv) / ...
		    ((p(nlab).*xx.*pax)'*(xx.*pbx) - m*alf/(vv*vv) +realmin) + v;
	end
end
W = setclass(W,classbit);
W = W.* max(v,0.1/(std(xx)+1e-16));
%help sigm=Sigmoidal transformation from map to classifier, producing   posterior probability estimates. 
%help log=natural logarithm of the elements of X.