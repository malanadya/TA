%HCLUST hierarchical clustering
% 
% 	labels = hclust(s,D,k)
% 	[labels, dendrogram] = hclust(s,D,k)
% 
% Computation of cluster labels and a dendrogram between the 
% clusters for objects with a given distance matrix D. k is the 
% desired number of clusters. The string s sets the clustering type:
% 
% 	's' : single linkage
% 	'c' : complete linkage
% 	Õa' : average linkage (weighted over cluster sizes)
% 
% The dendrogram is a 2*k matrix. The first row yields all cluster 
% sizes. The second row is the cluster level on which the set of 
% clusters starting at that position is merged with the set of 
% clusters just above it in the dendrogram. A dendrogram may be 
% plotted by plotdg.
% 
% 	dendrogram = hclust(s,D)
% 
% Returns just the dendrogram. Now the first row of the dendrogram 
% contains the original object numbers.
% 
% See also plotdg, kmeans, kcentres, modeseek

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [labels, dendrogram] = hclust(s,D,k)
if (nargout>1) & (nargin<3)
  error('Please supply k if you want also labels as output.');
end
[m,m1] = size(D);
if m ~= m1
	error('Input matrix should be square')
end
D = D + diag(inf*ones(1,m));     % set diagonal at infinity.
W = linspace(1,m+1,m+1);     % starting points of clusters
     % in linear object set.
V = linspace(1,m+2,m+2);     % positions of objects in final
     % linear object set
F = inf * ones(1,m+1);     % distance of next cluster to
     % previous cluster to be stored
     % at first point of second cluster
Z = ones(1,m);
for n = 1:m-1
     % find minimum distance D(i,j) i<j
	[di,I] = min(D); [dj,j] = min(di); i = I(j);
	if i > j, j1 = j; j = i; i = j1; end
	     % combine clusters i,j
  if strcmp(s,'s')
		D(i,:) = min(D(i,:),D(j,:));
	elseif strcmp(s,'c')
		D(i,:) = max(D(i,:),D(j,:));
	elseif strcmp(s,'a')
		D(i,:) = (Z(i)*D(i,:) + Z(j)*D(j,:))/(Z(i)+Z(j));
		Z(i:j-1) = [Z(i)+Z(j),Z(i+1:j-1)]; Z(j) = [];
	else
		error('Illegal clustertype desired')
	end
	D(:,i) = D(i,:)';
	D(i,i) = inf;
	D(j,:) = []; D(:,j) = [];
     % store cluster distance
	F(V(j)) = dj;
     % move second cluster in linear
     % ordering right after first cluster
	IV = [1:V(i+1)-1,V(j):V(j+1)-1,V(i+1):V(j)-1,V(j+1):m+1];
	W = W(IV); F = F(IV);     % keep track of object positions
     % and cluster distances
	V = [V(1:i),V(i+1:j) + V(j+1) - V(j),V(j+2:m-n+3)];
end
if nargin == 3     % find k clusters
	labels = zeros(1,m); 
	S = sort(-F); t = -S(k+1);     % find cluster level
	I = [find(F >= t),m+1];% find all indices where cluster starts
	for i = 1:k     % find for all objects cluster labels
		labels(W(I(i):I(i+1)-1)) = i * ones(1,I(i+1)-I(i));
	end     % compute dendrogram
	dendrogram = [I(2:k+1) - I(1:k); F(I(1:k))];
else     % no clustering desired, return
	labels = [W(1:m);F(1:m)];     % dendrogram as output argument
end
return
	
