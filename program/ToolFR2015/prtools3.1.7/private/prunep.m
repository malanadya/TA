%PRUNEP Pessimistic pruning of a decision tree
% 
% 	tree = prunep(tree,a,nlab,num)
% 
% Must be called by giving a tree and the training set a. num is the 
% starting node, if omitted pruning starts at the root. Pessimistic 
% pruning is defined by Quinlan.
% 
% See also maketree, treec, mapt 

% Guido te Brake, TWI/SSOR, TU Delft.
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function tree = prunep(tree,a,nlab,num)
if nargin < 4, num = 1; end;
[N,k] = size(a);
c = size(tree,2)-4;
if tree(num,3) == 0, return, end;
w = mapping('treec',tree,[1:c]',k,c,1,num);
ttt=tree_map(dataset(a,nlab),w);
J = testd(ttt)*N;
EA = J + nleaves(tree,num)./2;   % expected number of errors in tree
P = sum(expandd(nlab,c),1);     % distribution of classes
%disp([length(P) c])
[pm,cm] = max(P);     % most frequent class
E = N - pm;     % errors if substituted by leave
SD = sqrt((EA * (N - EA))/N);
if (E + 0.5) < (EA + SD)	     % clean tree while removing nodes
	[mt,kt] = size(tree);
	nodes = zeros(mt,1); nodes(num) = 1; n = 0;
	while sum(nodes) > n;	     % find all nodes to be removed
		n = sum(nodes);
		J = find(tree(:,3)>0 & nodes==1);
		nodes(tree(J,3)) = ones(length(J),1); 
		nodes(tree(J,4)) = ones(length(J),1); 
	end
	tree(num,:) = [cm 0 0 0 P/N];
	nodes(num) = 0; nc = cumsum(nodes);
	J = find(tree(:,3)>0);% update internal references
	tree(J,[3 4]) = tree(J,[3 4]) - reshape(nc(tree(J,[3 4])),length(J),2);
	tree = tree(~nodes,:);% remove obsolete nodes
else 
	K1 = find(a(:,tree(num,1)) <= tree(num,2));
	K2 = find(a(:,tree(num,1)) >  tree(num,2));

	tree = prunep(tree,a(K1,:),nlab(K1),tree(num,3));
	tree = prunep(tree,a(K2,:),nlab(K2),tree(num,4));
end
return
