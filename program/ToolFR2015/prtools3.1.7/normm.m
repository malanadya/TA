%NORMM Object normalization map
% 
% 	B = A*normm(p)
% 	B = normm(A,p)
% 
% Normalizes the distances of all objects in the dataset A such that 
% their Minkowski-p distance to the origin is one. For p=1 (default)  
% this is useful for normalizing probabilities. For 1-dimensional 
% datasets (size(A,2)=1) a second feature is added before 
% normalization such that A(:,2) = 1 - A(:,1).
% 
% See also mappings, datasets, classc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = normm(a,p)
if nargin == 0 
	w = mapping('normm','fixed',1);
elseif nargin == 2 & isempty(a)
	w = mapping('normm','fixed',p);
elseif (nargin == 1 & (isa(a,'dataset') | length(a) > 1)) | nargin == 2
   [nlab,lablist,m,k,c,prob,featlist] = dataset(a); 
   if k == 1
      a = [a 1-a]; k = 2;
      if size(featlist,1) < 2
         error('No two class-names found; probably wrong dataset used')
      else
         a = dataset(a,[],[featlist(1,:);featlist(2,:)]);
      end
   end
   if nargin == 1, p = 1; end
   if p == 1
	   s = sum(abs(a),2);
	else
		s = sum(abs(a).^p,2).^(1/p);
	end
	J = find(s~=0);
	w = a;
	w(J,:) = a(J,:)./repmat(s(J,1),1,k);
elseif nargin == 1 & isa(a,'double') & length(a) == 1
	w = mapping('normm','fixed',a);
else
	error('Operation undefined')
end
return
