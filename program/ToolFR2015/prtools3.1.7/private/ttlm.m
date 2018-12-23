function [v,i,tr,mu] = ttlm(v,f,n,p,t,tp,fid)
%TTLM Train feed-forward network w/Levenberg-Marquardt.
%	
%	[W,TE,TR] = TTLM(W,F,N,P,T,TP,FID)
%	  W  - weights and biases (a reshaped row vector).
%	  F  - Transfer function (string) of ith layer.
%	  N  - a row vector with the elements of the vector 
%	       specifying the number of neurons per layer. 
%	  P  - RxQ matrix of input vectors.
%	  T  - SxQ matrix of target vectors.
%	  TP - Training parameters (optional).
%    FID- file pointer for progress report (default 0)
%	Returns:
%	  W  - new weights and new biases (a reshaped row vector).
%	  TE - the actual number of epochs trained.
%	  TR - training record: [row of errors]
%	
%	Training parameters are:
%	  TP(1) - Epochs between updating display, default = 25.
%	  TP(2) - Maximum number of epochs to train, default = 1000.
%	  TP(3) - Sum-squared error goal, default = 0.02.
%	  TP(4) - Minimum gradient, default = 0.0001.
%	  TP(5) - Initial value for MU, default = 0.001.
%	  TP(6) - Multiplier for increasing MU, default = 10.
%	  TP(7) - Multiplier for decreasing MU, default = 0.1.
%	  TP(8) - Maximum value for MU, default = 1e10.
%	Missing parameters and NaN's are replaced with defaults.

% Mark Beale, 12-15-93
% Copyright (c) 1992-94 by the MathWorks, Inc.
% $Revision: 1.3 $  $Date: 1994/04/26 19:45:05 $
% Multi-layer adaptations by Bob Duin, 1997/07/28

if nargin < 5,error('Not enough arguments.'),end

% TRAINING PARAMETERS
if nargin == 5, tp = []; end
tp = nndef(tp,[25 1000 0.02 0.0001 0.001 10 0.1 1e30]);
me = tp(2);
eg = tp(3);
grad_min = tp(4);
mu_init = tp(5);
mu_inc = tp(6);
mu_dec = tp(7);
mu_max = tp(8);
[r,q] = size(p);
[s,qt] = size(t);
if q~=qt, error('Sample sizes do not match'); end
nl = length(n)+1;
df = [];
for j = 1:nl
	df = str2mat(df,feval(deblank(f(j,:)),'delta'));
end
df(1,:) = [];

% DEFINE SIZES
wmt = 0; amt = 0;
wm1 = zeros(1,nl); 
wm2 = wm1; bm1 = wm1; bm2 = wm1; am1 = wm1; am2 = wm1;
wn1 = zeros(1,nl); wn2 = wn1;
n = [n(:)',s];
nn = [r,n];

w = [];
vt = 0;
for j = 1:length(n);
	ww = reshape(v(vt+1:vt+(nn(j)+1)*n(j)),nn(j)+1,n(j));
	bb = ww(nn(j)+1,:); ww(nn(j)+1,:) = []; ww = ww';
	w = [w ww(:)' bb(:)'];
	vt= vt + (nn(j)+1)*n(j);
end
% COMPUTE ADDRESSES
for k = 1:nl
	wm1(k) = wmt+1; wm2(k) = wmt+nn(k)*n(k); wmt = wm2(k);
	bm1(k) = wmt+1; bm2(k) = wmt+n(k); wmt = bm2(k);
	am1(k) = amt+1; am2(k) = amt+n(k); amt = am2(k);
end
		
ii = eye(wmt);
ext_p = nncpyi(p,s);

% PRESENTATION PHASE
aa = p; a = [];
for k = 1:nl
	aa = feval(deblank(f(k,:)),reshape(w(wm1(k):wm2(k)),n(k),nn(k))*aa+w(bm1(k):bm2(k))'*ones(1,q));
	a = [a; aa];
end
e = t - aa;
SSE = sumsqr(e)/(q*s);

% TRAINING RECORD
tr = zeros(1,me+1);
tr(1) = SSE;

mu = mu_init; 
for i=1:me

  % CHECK PHASE
  if SSE < eg, i=i-1; break, end

  % FIND JACOBIAN
  ext_a = [];
  for k = 1:nl-1
  		ext_a = [ext_a; nncpyi(a(am1(k):am2(k),:),s);];
  end
  d = feval(df(nl,:),a(am1(nl):am2(nl),:));
  extd = -nncpyd(d);
  ext_d = extd;
  for k = (nl-1):-1:1
	extd = feval(df(k,:),ext_a(am1(k):am2(k),:),extd,reshape(w(wm1(k+1):wm2(k+1)),n(k+1),nn(k+1)));
  	ext_d = [extd;ext_d];
  end
  extd = ext_d(am1(1):am2(1),:);
  j = [learnlm(ext_p,extd),extd'];
  for k = 2:nl
  	extd = ext_d(am1(k):am2(k),:);
  	j = [j,learnlm(ext_a(am1(k-1):am2(k-1),:),extd),extd'];
  end

  % CHECK MAGNITUDE OF GRADIENT
  je = j' * e(:);
		grad = norm(je);
		if grad < grad_min, i=i-1; break, end

  % INNER LOOP, INCREASE MU UNTIL THE ERRORS ARE REDUCED
  jj = j'*j;
  pp = p + randn(r,q).*(ones(r,1)*std(p)*0.0);
  while (mu <= mu_max)
  %disp([size(ii) mu det(jj+ii*mu) rank(jj+ii*mu)])
  	dx = -(jj+ii*mu) \ je; 
	new_w = w + dx';
	
    % EVALUATE NEW NETWORK
	aa = pp; a = [];
	for k = 1:nl
		aa = feval(deblank(f(k,:)),reshape(new_w(wm1(k):wm2(k)),n(k),nn(k))*aa+new_w(bm1(k):bm2(k))'*ones(1,q));
		a = [a; aa];
	end
	new_e = t - aa;
	new_SSE = sumsqr(new_e)/(q*s);
    
    if (new_SSE < SSE), break, end
    mu = mu * mu_inc;
	
  end
  if (mu > mu_max), i = i-1; break, end
  mu = mu * mu_dec;

  % UPDATE NETWORK
  w = new_w; e = new_e; SSE = new_SSE;

  %fprintf(fid,'epochs:%5i  mse: %5.3e  grad: %5.3e  mu: %5.3e\n',i,SSE,grad,mu);

  % TRAINING RECORD
  tr(i+1) = SSE;

end

% TRAINING RECORD
tr = tr(1:(i+1));

v = []; vt = 0;
for j = 1:length(n)
	wm1 = vt+1; wm2 = vt+nn(j)*n(j);
	bm1 = vt+nn(j)*n(j)+1; bm2 = vt+(nn(j)+1)*n(j);
	ww = [reshape(w(wm1:wm2),n(j),nn(j))';w(bm1:bm2)];
	v = [v,ww(:)']; vt = vt+(nn(j)+1)*n(j);
end
