%NMC Nearest Mean Classifier
% 
% 	W = nmc(A)
% 
% Computation of the nearest mean classifier between the classes in 
% the dataset A.
% 
% See also datasets, mappings, nmsc, ldc, fisherc, qdc, udc 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = nmc(a)
if nargin < 1 | isempty(a)
	W = mapping('nmc');
	return
end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
if c == 2	% 2-class case: store linear classifier
	if isa(nlab,'dataset')
		u1 = +(nlab(:,1)'*a)/sum(+nlab(:,1));
		u2 = +(nlab(:,2)'*a)/sum(+nlab(:,2));
	else
		J1 = find(nlab==1);
		J2 = find(nlab==2);
		u1 = mean(+a(J1,:));
		u2 = mean(+a(J2,:));
	end
	w = [u1-u2,(u2*u2' - u1*u1')/2];
	W = mapping('affine',w',lablist,k,1,1,imheight);
	W = cnormc(W,a);
else		% multiclass case, store as 1-nn classifier
	if isa(nlab,'dataset')
		u = nlab'*a;
	else
		u = zeros(c,k);
		for i=1:c
			u(i,:) = mean(a(find(nlab==i),:),1);
		end
	end
	W = knnc(dataset(u,lablist),1);
end
return

