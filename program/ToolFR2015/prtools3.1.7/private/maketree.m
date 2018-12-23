%MAKETREE General tree building algorithm
% 
% 	tree = maketree(A,nlab,c,crit,stop)
% 
% Constructs a binary decision tree using the criterion function 
% specified in the string crit ('maxcrit', 'fishcrit' or 'infcrit' 
% (default)) for a set of objects A. stop is an optional argument 
% defining early stopping according to the Chi-squared test as 
% defined by Quinlan [1]. stop = 0 (default) gives a perfect tree 
% (no pruning) stop = 3 gives a pruned version stop = 10 a heavily 
% pruned version. 
% 
% Definition of the resulting tree:
% 
% 	tree(n,1) - feature number to be used in node n
% 	tree(n,2) - threshold t to be used
% 	tree(n,3) - node to be processed if value <= t
% 	tree(n,4) - node to be processed if value > t
% 	tree(n,5:4+c) - aposteriori probabilities for all classes in
% 			node n
% 
% If tree(n,3) == 0, stop, class in tree(n,1)
% 
% This is a low-level routine called by treec.
% 
% See also infstop, infcrit, maxcrit, fishcrit and mapt.

% Authors: Guido te Brake, TWI/SSOR, Delft University of Technology
%     R.P.W. Duin, TN/PH, Delft University of Technology
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function tree = maketree(a,nlab,c,crit,stop)
[m,k] = size(a); 

global contatore
contatore=contatore+1;

if nargin < 5, stop = 0; end;
if nargin < 4, crit = []; end;
if isempty(crit), crit = 'infcrit'; end;
if all([nlab == nlab(1)])
	p = ones(1,c)/(m+c); p(nlab(1)) = (m+1)/(m+c);
    %p = gones(1,c)/(m+c); p(nlab(1)) = (m+1)/(m+c);
	tree = [nlab(1),0,0,0,p];
else
	[f,j,t] = feval(crit,+a,nlab); % use desired split criterion
	crt = infstop(+a,nlab,j,t);    % use desired early stopping criterion
	p = sum(expandd(nlab),1);
	if length(p) < c, p = [p,zeros(1,c-length(p))]; end
    
    J = find(a(:,j) <= t);
    K = find(a(:,j) > t);
    
	if crt > stop & contatore<490 & length(J)>0 & length(K)>0 %evitare troppe ricorsioni  
		J = find(a(:,j) <= t);
		tl = maketree(+a(J,:),nlab(J),c,crit,stop);
		K = find(a(:,j) > t);
		tr = maketree(+a(K,:),nlab(K),c,crit,stop);
		[t1,t2] = size(tl);
		tl = tl + [zeros(t1,2) tl(:,[3 4])>0 zeros(t1,c)];
		[t3,t4] = size(tr);
		tr = tr + (t1+1)*[zeros(t3,2) tr(:,[3 4])>0 zeros(t3,c)];
		tree= [[j,t,2,t1+2,(p+1)/(m+c)]; tl; tr]; 
	else
		[mt,cmax] = max(p);
		tree = [cmax,0,0,0,(p+1)/(m+c)];
	end
end
return
