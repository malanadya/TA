%LOGLC Logistic Linear Classifier
% 
% 	W = loglc(A)
% 
% Computation of the linear classifier for the dataset A by 
% maximizing the likelihood criterion using the logistic (sigmoid) 
% function.
% 
% See also mappings, datasets, ldc, fisherc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = loglc(a)
if nargin == 0 | isempty(a)
	W = mapping('loglc'); return;
end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
if c > 2
	w = [];
	for i=1:c
		mlab = 2 - (nlab == i);
		aa = dataset(a,mlab);
		w = [w,loglc(aa)];
	end
	W = w*mapping(cmapm(2*c,[1:2:2*c-1]),lablist);
else
	x = [+a,ones(m,1)];
	x(find(nlab==2),:) = -x(find(nlab==2),:);
	alf = sum(nlab==2)/sum(nlab==1);
	w = zeros(1,k+1);
	L = -inf; Lnew = -realmax;
	while abs(Lnew - L) > 0.0001
		pax = ones(m,1) ./ (1 + exp(-x*w')); pbx = 1 - pax;
		L = Lnew; Lnew = sum(log(pax)); 
		p2x = sqrt(pax.*pbx); 
		y = x .* p2x(:,ones(1,k+1));
		w = pbx' * x * pinv(y'*y) + w;
	end
	w(k+1) = w(k+1) + log(alf*p(1)/p(2));
	J = find(nlab==1);
	W = mapping('affine',w',lablist,k,1,1,imheight);
end
return

