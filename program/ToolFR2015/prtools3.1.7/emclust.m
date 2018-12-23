%EMCLUST Expectation - Maximization clustering
%
%	[D,V] = emclust(A,W,n)
%
% The untrained classifier W is used to update an initially labelled
% dataset A by the following two steps:
% 1. train W by V = A*W
% 2. relabel A by A = dataset(A,classd(A*V))
%
% This is repeated until the labelling doesn't change anymore. Then
% D = A*V is returned, which is the classification based on the final
% labelling. As this is stable, this final labelling can be retrieved
% by classd(D). V may be used for assigning new objects.
%
% If n is given, a random initialisation for n classes is made.
% Default: n = 2.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [d,v] = emclust(a,w,n)
if nargin < 3, n = 2; end
[lab2,lablist,m,k,c,p] = dataset(a);
if c == 1 | nargin > 2 % take care of initialisation if not supplied
	if m > 500     % use a (sub)set of at most 500 samples
		b = +gendat(+a,500);
	else
		b = +a;
	end
	s = +distm(b);  % use kcentres for initial labeling
	labs = kcentres(s,n);
	lab2 = dataset(b,labs)*nmc*a*classd;
end
if isa(lab2,'dataset')
	d = lab2;
	eps = 1;
	while eps > 1e-6
		a = dataset(a,d);
		lab = +d;
		v = a*(w*classc);
		d = a*v;
		eps = mean(mean((+d-lab).^2));
%		disp(eps)
	end
else
	lab1 = ones(m,1);
	while any(lab1~=lab2)  % EM loop, run until labeling is stable
		a = dataset(a,lab2);
%		disp(sum(lab1~=lab2))
		lab1 = lab2;
		v = a*w;
		d = a*v;
		lab2 = classd(d);
	end
end
