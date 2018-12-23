%LMNM Levenberg-Marquardt neural net diabolo mapping
% 
% 	[W,R] = lmnm(A,n,iter,fid)
% 
% A linear n-dimensional mapping is found for the labeled dataset A
% using a diabolo network with a single hidden layer of n linear
% neurons and a classification output layer of sigmoidal neurons.
% Training is stopped after iter epochs (default infinity) or if its
% number is twice that of the best classification result. Progress
% is reported in fid (default: not), The entire training sequence is
% returned in R. Default n = 2. 
%
% See also datasets, mappings, nlklm, fisherm, klm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W, R] = lmnm(a,n,itermax,fid)
if nargin < 2, n = 2; end
if nargin < 3, itermax = []; end
if nargin < 4, fid = 0; end
if nargin == 0 | isempty(a)
	W = mapping('lmnm',{n,itermax,fid});
	return
end
[nlab,lablist,m,k,cout] = dataset(a);
if cout < 2
	error('Dataset should contain at least 2 classes')
end
if isempty(itermax), itermax = inf; end

				% pre-whitening
ww = klms(a);
a = a*ww;
[m,k] = size(a);

				% set targets
if cout > 1
	TAR = eye(cout); 
	%TAR(find(TAR==0)) = 0.1*ones(sum(sum(TAR==0)),1); 
	%TAR = reshape(TAR,cout,cout);
else
	TAR = [0 1];
end
T = TAR(nlab,:);
nl = length(n)+1;
nn = [k,n(:)',cout];
				% PCA initialisation
w = klm(+a,n(1));
v = +(a*w*fisherc);
u = zeros(n(1)+1,cout);
for j = 1:cout
	u(:,j) = +v{j};
end
w = +w;
w = [w(:)',u(:)'];
				% randomize lightly
r = rand(1,length(w))*0.05 + ones(1,length(w));
w = w.*r;

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
actf = ['purelin';'logsig '];
R = [];
while (iter <= 2*nmin | iter < 50) & iter < itermax
	[w,TE,TR] = ttlm(w,actf,n,a',T',TP,0);
	iter = iter + TE;
	W = mapping('affine',reshape(w(1:k*n(1)+n(1)),k+1,n(1)),[],k,n(1),1);
	W = W*(a*W*ldc);
	ea = testd(a,W);	
	RR = [iter ea];
	R = [R; RR];
%	fprintf('.');
	if ea < emin				% if better, store
		emin = ea;
		v = w;
		nmin = iter;
%		fprintf('\n%3.3f',e);
	end
	fprintf(fid,'epochs:%5i  ea: %3.3f  min_error: %3.3f\n', RR,emin);
	if TE == 0, break; end
end
v1 = reshape(v(1:k*n(1)+n(1)),k+1,n(1));
W = ww*mapping('affine',v1,[],k,n(1),1);
