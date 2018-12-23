%NORMAL_MAP Map a dataset on a normal densities based classifier
% 
% 	F = normal_map(A,W)
% 
% Maps the dataset A by the normal densities based classfier W on a 
% [0,1] interval for each of the classes W is trained on. This routine
% is automatically called for computing A*W if W is a normal density
% based classifier.
% A*W*sigm   or F*sigm   generates 0-1 scaled densities weighted by
%                        the class prior probabilities.
% A*W*classc or F*classc generates normalized posterior probabilities.
%
% scatterd(A); plotm(F*sigm) plots density contour lines.
% 
% See also mappings, datasets, udc, ldc, qdc, nbayesc, plotm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function F = normal_map(A,W)

[w,classlist,type,k,c,v,par] = mapping(W);
deg = ndims(w{2})-1;
U = +w{1}; G = w{2}; p = w{3};

[m,ka] = size(A);
if ka ~= k, error('Wrong feature size'); end

F = zeros(m,c);
if deg == 1
	H = G;
	if rank(H) < size(H,1)
		E = real(pinv(H));
	else
		E = real(inv(H));
	end
end
Cmax = -inf;
for i=1:c
	X = +A - ones(m,1)*U(i,:);
	if deg == 2
		H = G(:,:,i);
		if rank(H) < size(H,1)
			E = real(pinv(H));
		else
			E = real(inv(H));
		end
	end
	C = log(p(i)) - 0.5*(sum(log(real(eig(H))+realmin)) + log(2*pi));
	Cmax = max(C,Cmax);
	F(:,i) = (C - sum(X'.*(E*X'),1).*0.5)'; 
end

F = F - Cmax; % take care of scaling on 0-1
F = exp(F) + realmin;
F = invsig(F);
[nlab,lablist,m,k,c,p,classlista,imheight] = dataset(A);
if imheight > 0, imheight = 0; end
F = dataset(F,getlab(A),classlist,p,lablist,imheight);
return
