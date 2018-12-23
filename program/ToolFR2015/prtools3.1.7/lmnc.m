%LMNC Levenberg-Marquardt neural net classifier
% 
% 	[W,R] = lmnc(A,n,iter,Win,T,fid)
% 
% A feedforward neural network classifier with length(n) hidden 
% layer with n(i) units is computed for the dataset A. Training is 
% stopped after iter epochs (default infinity) or if its number is 
% twice that of the best classification result. This is measured by 
% the labeled tuning set T. If no tuning set is supplied A is used. 
% Win is used, if given, as network initialisation. Use [] if the 
% standard Matlab initialisation is desired. Progress is reported in 
% file fid (default 0). The entire training sequence is returned in 
% R: (number of epochs, classification error on A, classification 
% error on T, mse on A and mse on T).
% 
% See also mappings, datasets, bpxnc, neurc, rnnc, rbnc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W, R] = lmnc(a,n,itermax,W1,t,fid)
if nargin < 6, fid = 0; end
if nargin < 5 | isempty(t), t = a; end
if nargin < 4, W1 = []; end
if nargin < 3, itermax = []; end
if isempty(itermax), itermax = inf; end
if nargin < 2, n = 5; end
if nargin < 1 | isempty(a)
        W = mapping('lmnc',{n,itermax,W1,t,fid});
        return
end
[nlab,lablist,m,k,c] = dataset(a);
[nlabt,lablistt,mt,kt,ct] = dataset(t);
if kt ~= k
	error('Number of features of tuning set and training set do not match');
end
if ct ~= c
	error('Number of classes of tuning set and training set do not match');
end
				% scale at [0,1]
WS = scalem(a,'domain');
a = a*WS;
t = t*WS;
parw = double(WS);
u = parw{1};
s = 1./parw{2};
				% set number of network outputs
if c == 2
	cout = 1;
else
	cout = c;
end
				% set targets
if cout > 1
	TAR = eye(cout)*0.9; 
	TAR(find(TAR==0)) = 0.1*ones(sum(sum(TAR==0)),1); 
	TAR = reshape(TAR,cout,cout);
else
	TAR = [0.9; 0.1];
end
T = TAR(nlab,:)';
TT = TAR(nlabt,:)';
nl = length(n)+1;
nn = [k,n(:)',cout];

if isempty(W1)
				% use Nguyen-Widrow initialisation
   w = [];
   for j =1:nl
		if j == nl
			[w1,b1] = rands(nn(j+1),nn(j));
		else
			[w1,b1] = nwlog(nn(j+1),nn(j));
		end
		w1 = [w1';b1'];
		w = [w,w1(:)'];
	end
   
else
				% use give initialisation
	%error('Given initialisation under reconstruction')
	[w,lab,typew,kw,cw,vw,nw] = mapping(W1);
	if ~strcmp(typew,'neurnet') | kw ~= k | cw ~= cout | ~all(nw==nn)
		error('Incorrect initialisation network supplied')
	end
	[nlab1,nlab,lablist2] = renumlab(lablist,lab);
	if max(nlab) > c
		error('Initialisation network should be trained on same classes')
	end
	v1 = reshape(w(1:k*n(1)+n(1)),k+1,n(1));
	v1(k+1,:) = v1(k+1,:) + u*v1(1:k,:);
	v1(1:k,:) = v1(1:k,:).*(s'*ones(1,n(1)));
	w(1:k*n(1)+n(1)) = v1(:);
end
				% set standard training parameters
disp_freq = inf;
max_epoch = min(1,itermax); % this is our iteration unity
err_goal = 0.02;
min_grad = 1e-6;
init_mu = 0.001;
mu_inc = 10;
mu_dec = 0.1;
mu_max = 1e10;
TP = [disp_freq, max_epoch, err_goal, min_grad, init_mu, ...
    mu_inc, mu_dec, mu_max];
	 			% initialize loop and run
emin = 1;
nmin = 1;
iter = 0;
actf = setstr(ones(nl,1)*'logsig');
%fprintf('\nlmnnc');
R = [];
while (iter <= 2*nmin | iter < 50) & iter < itermax
	[w,TE,TR] = ttlm(w,actf,n,+a',T,TP,0);
	iter = iter + TE;
	W = mapping('neurnet',w,lablist,k,cout,1,nn);
	msea = mean((sigm(a*W)-T').^2);
	mset = mean((sigm(t*W)-TT').^2);
	ea = testd(a,W);	
	et = testd(t,W);	% error on tuning set
	RR = [iter ea et msea mset mean((w).^2)];
	R = [R; RR];
%	fprintf('.');
	if et < emin				% if better, store
		emin = et;
		v = w;
		nmin = iter;
%		fprintf('\n%3.3f',e);
	end
% 	fprintf(fid,'epochs:%5i  ea: %3.3f  et: %3.3f  msea: %3.3f  mset: %3.3f mean-w^2: %3.3f min_error: %3.3f\n', RR,emin);
	if TE == 0, break; end
end
%fprintf('\n');					% bring scaling into classifier and pack
v1 = reshape(v(1:k*n(1)+n(1)),k+1,n(1));
v1(1:k,:) = v1(1:k,:)./(s'*ones(1,n(1)));
v1(k+1,:) = v1(k+1,:) - u*v1(1:k,:);
v(1:k*n(1)+n(1)) = v1(:);
W = mapping('neurnet',v,lablist,k,cout,1,nn);