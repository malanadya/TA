%MATCHLAB Compare two labelings and rotate labels for optimal match
%
%  labels = matchlab(labels1,labels2)
%
% labels1 and labels2 are labelsets for the same objects. The returned
% labels constitute a rotated version of labels2, such that the difference
% with labels1 is minimized.

function lab = matchlab(lab1,lab2)
c = confmat(lab1,lab2);
[nl1,nl2,lablist] = renumlab(lab1,lab2);
[n1,n2] = size(c);
m = size(lab1,1);
L = zeros(1,n2);
K = [1:n1];
N = max(c(K,:),[],2) - sum(c(K,:),2);
[NN,R] = sort(N);
for j=1:n1
	[NN,r] = min(sum(c(:,K),1) - max(c(:,K),[],1));
	k = K(r);
	[nn,s] = max(c(:,k));
	L(k) = s;
	c(:,k) = zeros(n1,1);
	K(r) = [];
end
lab = lablist(L(nl2),:);
