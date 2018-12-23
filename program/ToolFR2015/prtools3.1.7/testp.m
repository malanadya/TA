%TESTP Error estimation of Parzen classifier
% 
% 	e = testp(A,h,T)
% 
% Tests a dataset T on dataset A using a Parzen classification and 
% returns the classification error e. 
% 
% 	e = testp(A,h)
% 
% returns the leave-one-out error estimate. If h is not given, it is 
% determined by parzenc.
% 
% See also datasets, mappings, parzenml, parzenc. 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function e = testp(a,h,t)
if nargin < 2, [W,h] = parzenc(a); end
[nlab,lablist,m,k,c,p] = dataset(a);
if length(h) == 1, h = h*ones(1,c); end
if length(h) ~= c, error('Wrong number of smoothing parameters'); end
if nargin <= 2
	d = classp(a,nlab,h,p);
	[dmax,J] = max(d',[],1);
	e = nstrcmp(lablist(J,:),lablist(nlab,:)) / m;
elseif nargin == 3
   [nlabt,lablistt,n,kt] = dataset(t);
   [n,kt] = size(t);
	if k ~= kt 
		error('Data sizes do not match');
	end
	d = classp(a,nlab,h,p,t); [dmax,J] = max(d',[],1);
	e = nstrcmp(lablistt(J,:),lablistt(nlabt,:)) / n;
end
return

function F = classp(a,nlab,h,p,t)
[m,k] = size(a);
maxa = max(max(abs(a)));
a = a/maxa;
h = h/maxa;
if nargin < 5
   mt = m;
else
   [mt,kt] = size(t);
   t = t/maxa;
end
c = max(nlab);
alf=sqrt(2*pi)^k;
[num,n] = prmem(mt,m);
F = ones(mt,c);
for i = 0:num-1
	if i == num-1
		nn = mt - num*n + n;
	else
		nn = n;
	end
	range = [i*n+1:i*n+nn];
	if nargin <= 4
		D = +distm(a,a(range,:));
		D(i*n+1:m+1:i*n+nn*m) = inf*ones(1,nn); % set distances to itself at inf
	else
		D = +distm(a,t(range,:));
	end
	for i=1:c
		I = find(nlab == i);
		if length(I) > 0
			F(range,i) = p(i).*sum(exp(-D(I,:)*0.5./(h(i).^2)),1)'./(length(I)*alf*h(i)^k);
		end
	end
end
F = F + realmin;
F = F ./ (sum(F')'*ones(1,c));
return
