%PARZENC Optimisation of the Parzen classifier
% 
% 	[W,h,e] = parzenc(A)
% 
% Computation of the optimum smoothing parameter h for the Parzen 
% classifier between the classes in the dataset A. The leave-one-out 
% Lissack & Fu estimate is used for the classification error e. The 
% final classifier is stored as a mapping in W. It may be converted
% into a classifier by W*classc.
% 
% 	W = parzenc(A,h)
% 
% No learning, just the discriminant W is produced for the given 
% smoothing parameter h. It should either be a scalar (same 
% smoothing parameter for all classes) or a vector with a value for 
% each class.
% 
% See also mappings, datasets, parzen_map, testp, parzenml, classc
 
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,h,e] = parzenc(a,h)
if nargin == 0, W = mapping('parzenc'); return; end
if isempty(a), W = mapping('parzenc',h); return; end
[nlab,lablist,m,k,c,p] = dataset(a);

if nargin == 2
	if length(h) == 1, h = h(ones(1,c)); end
	if length(h) ~= c
		error('Smoothing parameter vector has wrong length')
   end
   W = mapping('parzen_mapSupervised',a,lablist,k,c,1,h);
   return
end

		% compute all object distances
D = +distm(a) + diag(inf*ones(1,m));
		% find object weights q
q = classsizes(a);
		% find for each object its class freqency
of = q(nlab)';
		% find object weights q
q = p(nlab)'./q(nlab)';
		% initialise
h = max(std(a));
L = -inf;
Ln = 0;
z = 0.1^(1/k);
		% iterate
while abs(Ln-L) > 0.001 & z < 1
	if Ln > L, L = Ln; end
	r = -0.5/(h^2);
	F = q(ones(1,m),:)'.*exp(D*r); 			% density contributions
	FS = sum(F)*((m-1)/m); IFS = find(FS>0);      % joint density distribution
	G = sum(F .* (nlab(:,ones(1,m)) == nlab(:,ones(1,m))'));
	G = G.*(of-1)./of;						% true-class densities
	
			% ML estimate, neglect zeros
			
	en = max(p)*ones(1,m);
	en(IFS) = (G(IFS))./FS(IFS);
	Ln = exp(sum(log(en))/m);
	%fprintf('h = %6.4f, Ln = %6.4f, L = %6.4f\n',h,Ln,L);
	if Ln < L 					% compute next estimate
		z = sqrt(z);			% adjust stepsize
		h = h / z;
	else
		h = h * z;
	end
end
W = mapping('parzen_mapSupervised',a,lablist,k,c,1,h*ones(1,c));
return
