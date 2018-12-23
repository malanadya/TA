%TESTD Classification error estimate
% 
% 	[e,j,k,l] = testd(A,W,r,iter)
% 
% Test of dataset A on the classifier defined by W. Returns:
% 	e - the fraction of A that is incorrectly classified by W.
% 	j - the mean square error between the posterior probability
% 	    outputs of W for A and the 0/1 targets.
% 	k - mean confidence for classification
% 	l - minus the mean log likelihood for the true classes.
% 
% If W is an untrained classifier the error is estimated by r-fold 
% rotation, averaged over iter iterations.
% E.g. testd(fisherc,a,10,5).
% For r=1 a bootstrapped version of A is used for training and the 
% remaining objects are used for testing. Each of the error measures 
% e,j,k,l are for iter > 1 a 2-component vector, containing mean and 
% standard deviation.
% 
% 	[e,j,k,l] = testd(D)
% 
% Finds the error of the classified dataset. D is typically the 
% result of D = A*W*classc. 
% 
% This might also be written as
% 
% 	e = A * W * testd
% 
% or if W is found by, for instance, W = fisherc(B), as
% 
% 	e = B * fisherc * A * testd
% 
% See also mappings, datasets, classc, classd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [E,J,K,L] = testd(a,w,rot,iter)

if nargin == 0
	
	E = mapping('testd','fixed');

elseif nargin == 1
	if ~isa(a,'dataset')
		error('Dataset expected')
	end
	[nlab,lablist,m,k,c,prob] = dataset(a);
	labout = classd(a);[mm,l1] = size(lablist);
	[m,l2] = size(labout);
	if l1 ~= l2
		error('Object labels incompatible with classifier labels')
	end 
	E = 0; J = 0; L = 0; K = 0;
	for j = 1:c
		if isa(nlab,'dataset')
			if any(+a<0) | any(+a>1)
				warning('Dataset converted to probabilities'); 
				a = a*classc;
			end
			if size(nlab,2) == 2 & size(a,2) == 1
				a = [a 1-a];
			end
			e = mean(mean(+abs(a-nlab)));
			E = E + prob(j)*e;
		else
			M = find(nlab==j);
			[e,t] = nstrcmp(labout(M,:),lablist(nlab(M),:));
			E = E + prob(j)*e/length(M);
		end
		if nargout > 1		% mean square error
			a = real(double(a));
			if any(a(:)<0) | any(a(:)>1)
				error('No proper posterior probabilities supplied')
			end
			for q = 1:c
				J = J + mean(((nlab(M) == q) - a(M,q)).^2)*prob(j)*prob(q);
			end
		end
		if nargout > 2		% confidences for output labels
			q = max(a(M,:)')';
 			K = K + mean((q-t).^2)*prob(j);
		end
		if nargout > 3
			L = L - mean(log(a(find(nlab==j),j)+realmin))*prob(j);
		end
	end

elseif nargin == 2
	
	if nargout < 2
		E = testd(a*w);
	else
		a = a * classc(w);
		[E,J,K,L] = testd(a);
	end

elseif nargin >= 2 & ~istrained(w) & isa(w,'mapping')
	
	if nargin < 3, rot = 1; end
	if nargin < 4, iter = 1; end
	if isempty(a), E = mapping('testd','fixed',{w,rot,iter}); end
	[nlab,lablist,m,k,c,prob,featlist] = dataset(a);
	rot = min(rot,m);
	n = ceil(m/rot); rot1 = n*rot-m;
	Z = zeros(iter,4);
	for it = 1:iter
		if rot == 1 % bootstrapping
			[al,at] = gendat(a);
			[e1,e2,e3,e4] = testd(at*classc(al*w));
			Z(it,:) = [e1,e2,e3,e4];
		else
			% All this is necessary to randomize to order
			% while preserving a uniform class distribution
			R = randperm(m);
			N = zeros(1,m);
			Q = [1:m];
			for j = 1:c
				M = find(nlab(R)==j);
				nj = length(M);
				MQ = round([1:nj]*length(Q)/nj);
				MQ = MQ - floor(MQ(1)/2);
				N(Q(MQ)) = M;
				Q = find(N==0);
			end
			R = R(N);
			s = 1;
			for j = 1:rot
				if j <= rot1, q = n-1; else, q = n; end
				T = [s:s+q-1];
				P = [1:s-1 s+q:m];
				if nargout < 2
					Z(it,1)=Z(it,1)+testd(a(R(P),:) * w * a(R(T),:))*q;
				else
					[e1,e2,e3,e4]=testd(a(R(T),:)*classc(a(R(P),:)*w));
					Z(it,:) = Z(it,:) + [e1,e2,e3,e4]*q;
				end
				s = s+q;
			end
			Z(it,:) = Z(it,:)/m;
		end
	end
	Z = [mean(Z,1); std(Z,[],1)];
	E = Z(:,1); J = Z(:,2); K = Z(:,3); L = Z(:,4);
	
else

	error('Wrong number of parameters')
	
end
return

