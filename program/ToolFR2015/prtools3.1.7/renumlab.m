%RENUMLAB Renumber labels
% 
% 	[nlab,lablist] = renumlab(slab)
% 
% The array of labels slab is converted and renumberred to a vector 
% of numeric labels nlab. The conversion table lablist is such that 
% slab = lablist(nlab,:).  slab can be a set of numeric row vectors 
% or a set of strings.
% 
% 	[nlab1,nlab2,lablist] = renumlab(slab1,slab2)
% 
% This combines two input arrays of labels slab1 and slab2 into two 
% numeric label vectors nlab1 and nlab2 with a shared conversion 
% table lablist. 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [nlab,nlab2,lablist] = renumlab(slab,slab2)
str = 0;
if isempty(slab) & nargin == 1
	nlab = []; nlab2 = [];
	return
end
if isstr(slab)
	str = 1;
	slab = abs(slab);
end
if nargin == 2
	if isstr(slab2)
		str = 1;
		slab2 = abs(slab2);
	end
	[n1,m] = size(slab);
	[n2,m2] = size(slab2);
	if m < m2
		slab = [slab zeros(n1,m2-m)];
	elseif m2 < m
		slab2 = [slab2 zeros(n2,m-m2)];
	end
	m = max(m,m2);
	n = n1+n2;
	if ~isempty(slab2)
		slab = abs(str2mat(slab,slab2));
	end
else
	[n,m] = size(slab);
end
nlab = zeros(n,1);
lablist = zeros(n,m);

if m > 1	% Debugged by Oscar Deniz Suarez
	NumVistas=0;
	for i=1:n
		pos=strmatch(slab(i,:),lablist(1:NumVistas,:),'exact');
		if isempty(pos)
			NumVistas=NumVistas+1;
			lablist(NumVistas,:)=slab(i,:);
			nlab(i)=NumVistas;
		else
			nlab(i)=pos(1);
		end
	end
	lablist=lablist(1:NumVistas,:);
else
	i = 0;
	while min(nlab) == 0
		i = i+1;
		t = slab(min(find(nlab==0)),:);
		I = find(slab == t);
		nlab(I) = i*ones(size(I));
		lablist(i,:) = t;
	end
	lablist = lablist(1:i,:);
end

[lablist,J] = sortrows(lablist);
[JJ,J] = sort(J);
nlab = J(nlab);
if str
	lablist = setstr(lablist); 
end
if nargin == 2
	nlab2 = nlab(n1+1:n1+n2);
	nlab = nlab(1:n1);
else
	nlab2 = lablist;
end
return
	
