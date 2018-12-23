%INFCRIT The information gain and its the best feature split.
% 
% 	[f,j,t] = infcrit(A,nlabels)
% 
% Computes over all features the information gain f for its best 
% threshold from the dataset A and its numeric labels. For f=1: 
% perfect discrimination, f=0: complete mixture. j is the optimum 
% feature, t its threshold. This is a lowlevel routine called for 
% constructing decision trees.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [g,j,t] = infcrit(a,nlab)
[m,k] = size(a);
c = max(nlab);
mininfo = ones(k,2);
					% determine feature domains of interest
[sn,ln] = min(a,[],1); 
[sx,lx] = max(a,[],1);
JN = (nlab(:,ones(1,k)) == ones(m,1)*nlab(ln)') * realmax;
JX = -(nlab(:,ones(1,k)) == ones(m,1)*nlab(lx)') * realmax;
S = sort([sn; min(a+JN,[],1); max(a+JX,[],1); sx]);
			% S(2,:) to S(3,:) are interesting feature domains
P = sort(a);
Q = (P >= ones(m,1)*S(2,:)) & (P <= ones(m,1)*S(3,:));
			% these are the feature values in those domains
for f=1:k,		% repeat for all features
	af = a(:,f);
    if sum(sum(isnan(af)))
        continue
    end
	JQ = find(Q(:,f));
	SET = P(JQ,f)';
	if JQ(1) ~= 1
		SET = [P(JQ(1)-1,f), SET];
	end
	n = length(JQ);
	if JQ(n) ~= m
		SET = [SET, P(JQ(n)+1,f)];
	end
	n = length(SET) -1;
	T = (SET(1:n) + SET(2:n+1))/2; % all possible thresholds
	L = zeros(c,n); R = L;     % left and right node object counts per class
	for j = 1:c
		J = find(nlab==j); mj = length(J);
		if mj == 0
			L(j,:) = realmin*ones(1,n); R(j,:) = L(j,:);
		else
			L(j,:) = sum(repmat(af(J),1,n) <= repmat(T,mj,1)) + realmin;
			R(j,:) = sum(repmat(af(J),1,n) > repmat(T,mj,1)) + realmin;
		end
	end
	infomeas =  - (sum(L .* log10(L./(ones(c,1)*sum(L)))) ...
		+ sum(R .* log10(R./(ones(c,1)*sum(R))))) ...
		./ (log10(2)*(sum(L)+sum(R))); % criterion value for all thresholds
	[mininfo(f,1),j] = min(infomeas);     % finds the best
	mininfo(f,2) = T(j);     % and its threshold
end   
g = 1-mininfo(:,1)';
[finfo,j] = min(mininfo(:,1));		% best over all features
t = mininfo(j,2);			% and its threshold
return

