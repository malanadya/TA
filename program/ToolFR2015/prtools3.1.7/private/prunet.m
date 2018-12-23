%PRUNET Prune tree by testset
% 
% 	tree = prunet(tree,a)
% 
% The test set a is used to prune a decision tree. 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function tree = prunet(tree,a)
[m,k] = size(a);
[n,s] = size(tree);
c = s-4;
erre = zeros(1,n);
deln = zeros(1,n);
w = mapping('treec',tree,[1:c],k,c,1,1);
[f,lab,nn] = tree_map(a,w);  % bug, this works only if a is dataset, labels ???
[fmax,cmax] = max(tree(:,[5:4+c]),[],2);
nngood = nn([1:n]'+(cmax-1)*n);
errn = sum(nn,2) - nngood;% errors in each node
sd = 1;
while sd > 0
	erre = zeros(n,1);
	deln = zeros(1,n);
	endn = find(tree(:,3) == 0)';	% endnodes
	pendl = max(tree(:,3*ones(1,length(endn)))' == endn(ones(n,1),:)');
	pendr = max(tree(:,4*ones(1,length(endn)))' == endn(ones(n,1),:)');
	pend = find(pendl & pendr);		% parents of two endnodes
	erre(pend) = errn(tree(pend,3)) + errn(tree(pend,4));
	deln = pend(find(erre(pend) >= errn(pend))); % nodes to be leaved
	sd = length(deln);
	if sd > 0
		tree(tree(deln,3),:) = -1*ones(sd,s);
		tree(tree(deln,4),:) = -1*ones(sd,s);
		tree(deln,[1,2,3,4]) = [cmax(deln),zeros(sd,3)];
	end
end
return

