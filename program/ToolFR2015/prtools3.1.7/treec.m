%TREEC Build a decision tree classifier
% 
% 	W = treec(A,crit,prune,T)
% 
% Computation of a decision tree classifier out of a dataset A using 
% a binary splitting criterion crit:
% 	infcrit  -  information gain
% 	maxcrit  -  purity (gini value)
% 	fishcrit -  Fisher criterion
% 
% Pruning is defined by prune:
% 	prune = -1 pessimistic pruning as defined by Quinlan. 
% 	prune = -2 testset pruning using the dataset T, or, if not
% 	   supplied, an artificially generated testset of 5 x size of
% 	   the training set based on parzen density estimates.
% 	   see parzenml and gendatp.
% 	prune = 0 no pruning (default).
% 	prune > 0 early pruning, e.g. prune = 3
% 	prune = 10 causes heavy pruning.
% 
% see also mappings, datasets, tree_map

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = treec(a,crit,prune,t)

clear contatore
global contatore
contatore=1;

% if nargin == 0 | isempty(a)
% 	if nargin <2, w = mapping('treec');
% 	elseif nargin < 3, w = mapping('treec',crit);
% 	elseif nargin < 4, w = mapping('treec',{crit,prune});
% 	else, w = mapping('treec',{crit,prune,t});
% 	end
% 	return
% end
[nlab,lablist,m,k,c] = dataset(a);
if nargin == 1 | isempty(crit), crit = 2; end
if ~isstr(crit)
	if crit == 0 | crit == 1, crit = 'infcrit'; 
	elseif crit == 2, crit = 'maxcrit';
	elseif crit == 3, crit = 'fishcrit';
	else, error('Unknown criterion value');
	end
end
if nargin == 1
	tree = maketree(+a,nlab,c,crit);%CPU
    %tree = maketree(gsingle(+a),gsingle(nlab),c,crit);%CUDA

elseif nargin == 2
	tree = maketree(+a,nlab,c,crit);
elseif nargin > 2
	if prune == -1, prune = 'prunep'; end
	if prune == -2, prune = 'prunet'; end
	if isstr(prune)
		tree = maketree(+a,nlab,c,crit);
		if prune == 'prunep'
			tree = prunep(tree,a,nlab);
		elseif prune == 'prunet'
			if nargin < 4
				t = gendatt(a,5*sum(nlab==1),'parzen');
			end
			tree = prunet(tree,t);
		else
			error('unknown pruning option defined');
		end
	else
		tree = maketree(+a,nlab,c,crit,prune);
	end
else
	error('Wrong number of parameters')
end
w = mapping('tree_map',tree,lablist,k,c,1,1);
return

