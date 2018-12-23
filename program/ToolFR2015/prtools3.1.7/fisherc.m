%FISHERC Fisher's Least Square Linear Classifier
% 
% 	W = fisherc(A,mode,n)
% 
% Finds the linear discriminant function between the classes in the 
% dataset A by minimizing the errors in the least square sense. For 
% n > 1 (default n = 1) this is done iteratively. For increasing 
% iterations the more remote objects are weighted less. This might 
% give a considerable improvement for non- normally distributed 
% datasets, provided the number of samples is sufficiently large. As 
% the best classifier for  the training set is returned, a too large 
% value of n may cause overtraining.
% 
% The behavior for multi-class cases depends on the mode:
% 	'single' : (default) between each class and the combined
% 			set of other classes a single linear classifier
% 			is computed.
% 	'multi'  : for each of the c classes a combined linear
% 			classifier is computed separating it from the
% 			other c-1 classes. This increases the number
% 			of weights as well as the computing time by
% 			about a factor c. Objects are assigned to the
% 			class for wich the (combined) classifier yields
% 			the highest posterior probability.
% 
% See also: mappings, datasets, ldc, nmc, qdc 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = fisherc(a,mode,iter)
if nargin < 3, iter = 1; end
if nargin < 2, mode = 'single'; end
if nargin < 1 | isempty(a)
	W = mapping('fisherc',{mode,iter}); return
end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
if isempty(mode), mode = 'single'; end

if c > 2
	
	if strcmp(mode,'multi')

		W = [];
		for i1=1:c
			lab = lablist(i1,:);
			J1 = find(nlab==i1);
			mlab = ones(m,1);
			mlab(J1) = zeros(length(J1),1);
			aa = dataset(a,mlab);
			I1 = [1:c]; I1(i1) = [];
			w = mapping(fisherc(aa,mode,iter),lab);
			W = [W,w];
			for i2 = I1  
				J2 = find(nlab==i2);
				v = mapping(fisherc(aa([J1;J2],:),mode,iter),lab);
				W = [W,v];
			end
		end
		W = minc(W);

	elseif strcmp(mode,'single')

		W = [];
		for i=1:c
			mlab = 2 - (nlab == i); 
			aa = dataset(a,mlab);
			v = fisherc(aa,mode,iter);
			W = [W,mapping(v,lablist(i,:))];
		end

	else

		error('Unknown mode')

	end

else
	emin = 1;
	g = ones(m,1);
	y = 3-2*nlab;
	oa = ones(m,1);
	u = double(mean(a));
	aa = double([a - oa*u,oa]);
	for i = 1:iter
		if rank(aa) <= k
			v = (pinv(aa.*g(:,ones(1,k+1)))*(y.*g));
		else
			v = ((aa.*g(:,ones(1,k+1)))\(y.*g));
		end
		v(k+1) = v(k+1) - u*v(1:k);
		w = mapping('affine',v,lablist,k,1,1,imheight);
		w = cnormc(w,a);
		if iter == 1
			W = w; break;
		end
		[labout,d] = classd(w,a);
		e = testd(d);
%		fprintf('%4i  %3.4f \n',i,e);
		if e < emin
			emin = e; W = w;
		end
		if e == 0, break; end
		g = 2*(1 - max(d')').^(i/4);
	end
	
end
