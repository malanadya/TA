%CMAPM Compute some special maps
% 
% cmapm computes some special data independent maps for scaling, 
% selecting or rotating k-dimensional feature spaces.
% 
% 	W = cmapm(k,N)
% 
% Selects the features listed in the vector N
% 
% 	W = cmapm(k,'sigmoid')
% 	W = cmapm(k,'exp')
% 	W = cmapm(k,'nexp')
% 	W = cmapm(k,'log')
% 
% Defines sigmoidal (logistic), exponential, negative exponential 
% and logarithmic mappings.
% 
% 	W = cmapm(k,P)
% 
% Polynomial feature map. P should be a n*k matrix in which each row 
% defines the exponents for the orignal features in a polynomial 
% term. So P = [1 0; 0 1; 1 1; 2 0; 0 2; 3 0; 0 3] defines 7 
% features, the original 2 (e.g. x and y), a mixture (xy) and all 
% powers of the second (x^2, y^2) and third (x^3,y^3) order. Another 
% example is P = diag([0.5 0.5 0.5]) defining 3 features to be the 
% square roots of the original ones.
% 
% 	W = cmapm(k,'randrot')
% 
% Defines a random k-dimensional rotation.
% 
% 	W = cmapm(F,'rot')
% 
% The n*k matrix F defines n linear combinations to be computed by 
% x*F'.
% 
% 	W = cmapm(x,'shift');
% 
% Defines a shift of the origin to x.
% 
% 	W = cmapm(s,'scale');
% 
% Divide the features by the components of the vector s.
% 
% See also mappings, scalem, featselm, klm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = cmapm(q,s);
if nargin < 2
	error('Undefined input arguments')
end
if isstr(s)
	if strcmp(s,'sigmoid')
		w = mapping('sigmoid',[],[],q,q);
	elseif strcmp(s,'exp')
		w = mapping('exp',[],[],q,q);
	elseif strcmp(s,'nexp')
		w = mapping('nexp',[],[],q,q);
	elseif strcmp(s,'log')
		w = mapping('log',[],[],q,q);
	elseif strcmp(s,'randrot')
		[F,V] = eig(covm(randn(100*q,q)));
		F = [F;zeros(1,q)];
		w = mapping('affine',F,[],q,q);
	elseif strcmp(s,'rot')
		[n,k] = size(q); q = [q';zeros(1,n)];
		w = mapping('affine',q,[],k,n);
	elseif strcmp(s,'dist')
		[n,k] = size(q);
		w = mapping('dist',q,[],k,n);
	elseif strcmp(s,'shift')
		k = length(q);
		w = mapping('normalize',{q,ones(1,k),0},[],k,k);
	elseif strcmp(s,'scale')
		k = length(q);
		w = mapping('normalize',{zeros(1,k),ones(1,k)./q,0},[],k,k);
	else
		error('Unknown option')
	end
else
	if min(size(s)) == 1 & min(size(s)) < q
		w = mapping('featsel',s,[],q,length(s));
	else
		[n,k] = size(s);
		if q ~= k
			error('Matrix has wrong size')
		else
			w = mapping('polynomial',s,[],k,n);
		end
	end
end
return

