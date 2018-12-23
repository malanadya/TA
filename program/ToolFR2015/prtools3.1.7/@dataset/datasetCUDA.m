%DATASET Dataset class constructor
%
%	a = dataset(d,labels,featlist,prob,lablist,imheight)
%
% A dataset object is constructed from:
% d       size [m,k], a set of m datavectors of k features
% labels  size [m,n]  labels for each of the datavectors either
%                     in string or in numbers
% featlist size [k,f] defines the labels for the k features
% prob    size [c,1], apriori probabilities for each of the c classes
%                     prob = 0: all classes have equal probability 1/c
%                     prob = []: all datavectors are equally probable
% lablist size [c,n]  classlabels corresponding to the apriori probablities
%                     These should only be given if prob is given and not
%                     equal to 0 and not empty.
% imheight            If the rows of d (the data objects) are images then in
%                     imheight the vertical images size can be stored. If
%                     necessary (e.g. for display) an image is reconstructed
%                     by reshape(d(i,:),imheight,k/imheight).
%                     If imheight < 0 then -imheight is interpreted as the
%                     vertical image size of images stored as features, e.g.
%                     the color component of an image in case the pixels are
%                     the data objects. An image is now reconstructed by
%                     reshape(d(:,1),abs(imheight),m/abs(imheight))
%
%	a = dataset(a,labels,featlist)
%
% Redefines labels and / or features of given dataset.
%
%	[nlab,lablist,m,k,c,prob,featlist,imheight] = dataset(a)
%
% Retrieves parameters from given dataset.
% lablist is the set of c class labels. nlab is a set of numeric labels
% between 1 and c. lablist(nlab,:) returns the original set of labels.
% The set of datavectors d can be retrieved by
%
%	d = double(a), or just by d = +a;
%
% An affine mapping w can be transformed to a dataset by
%
%	a = dataset(w)

% a.d = d
% a.l = labels
% a.f = featlist
% a.p = prob
% a.ll = lablist
% a.c = imheight
% a.s = 0 (transpose)

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% CREATED
% Bob Duin, ??-??-2001
%
% REVISION HISTORY
% DR1 - Bob Duin & Dick de Ridder, 14-1-2002
% If measurements contain images, set imheight.
%
% DR2 - Dick de Ridder, 21-1-2002
% Added check whether number of samples == number of labels.
%
% DR3 - Dick de Ridder, 22-1-2002
% Added check whether number of features == number of feature labels (!#%*!).
% RD1 - Bob Duin, removed DR3, seems to be in error, 23-1-2002

function [nlab,lablist,m,k,c,prob,featlist,imheight] = dataset(a,labels,featlist,prob,lablist,imheight)
%disp('dataset')
if nargin > 1 & nargout > 1
	error('Dataset retrieval during redefinition not supported')
end
if nargin < 1, a = []; end
if nargin < 2, labels = []; end
if nargin < 3, featlist = []; end
if nargin < 4, prob = []; end
if nargin < 5, lablist = []; end
if nargin < 6, imheight = []; end
if isa(a,'dataset') & ~iscell(a.ll)
	[a.l,labl] = renumlab(a.l);
	a.ll = {labl};
elseif isa(a,'measurement')
	labels = getlab(a);
%DR1
	if (max(size(a{1})) > 1)
		imheight = size(a{1},1);
	end;
	a = +a;
end
[m,k] = size(a);
			% retrieval of dataset definition and parameters
if nargout > 1
	if ~isa(a,'dataset')
		a = dataset(a);
	end
	if a.s, mk = m; m = k; k = mk; end
	if ~isa(a.l,'dataset')
		c = max(a.l);
	else
		c = size(a.l,2);
	end
	lablist = a.ll{1};
	nlab = a.l;
	if isempty(a.p)
		if ~isa(nlab,'dataset')
			ee = (nlab(:,ones(1,c)) == ones(m,1) * linspace(1,c,c));
			prob = sum(ee)'/m;
		else
			prob = mean(+nlab)';
		end
	else
		prob = a.p;
	end
	featlist = a.f;
	imheight = a.c;
elseif isa(a,'dataset')
	if nargin == 1
		nlab = a;
		return
	end
			% redefinition of dataset
	if ~isempty(labels)
%DR2
		if size(labels,1) ~= m
			error('Wrong number of labels supplied')
		end

		if ~isa(labels,'dataset')
			[a.l,labl] = renumlab(labels);
		else
			labl = getfeat(labels);
			a.l = labels;
			[nl,labl] = renumlab(labl);
			labels.d = labels.d(:,nl);
			a.l = labels;
		end
		a.ll = {labl};
		a.p = [];
	end
	if ~isa(labels,'dataset')
		c = max(a.l);
	else
		c = size(a.ll{1},1);
	end
	if ~isempty(featlist)
%DR3, RD1
%		if size(featlist,1) ~= k
%			error('Wrong number of feature labels supplied')
%		end

		if iscell(featlist)
			a.f = char(featlist);
		else
			a.f = featlist;
		end
	end
	if ~isempty(lablist)
		nl2 = zeros(1,size(lablist,1));
		for i=1:size(lablist,1)
			n = strmatch(lablist(i,:),a.ll{1});
			if ~isempty(n)
				nl2(i) = n;
			else
				a.ll = {str2mat(a.ll{1},lablist(i,:))};
				nl2(i) = size(a.ll{1},1);
			end
		end
		if length(nl2) < c
			error('Labellist does not correspond to set of labels')
		end
	else
		nl2 = [];
	end
	if ~isempty(prob)
		if prob == 0
			prob = ones(c,1)/c;
		end
		if isempty(nl2)
			a.p = prob(:);
		else
			if length(prob) ~= length(nl2)
				error('Wrong number of probabilities supplied')
			end
			a.p = zeros(max(nl2),1);
			for i=1:c
				j = find(nl2==a.l(i));
				%if length(j) ~= 1
				%	error('Labellist does not correspond to set of labels')
				%end
				a.p(i) = sum(prob(j));
			end
		end
	end
	a.p = a.p ./ sum(a.p);
	if ~isempty(imheight) a.c = imheight; end
	if imheight > 0 & imheight*round(k/imheight) ~= k
		error('Image height inconsistent with data feature size')
	end
	if imheight < 0 & imheight*round(m/imheight) ~= m
		error('Image height inconsistent with data size')
	end
	nlab = a;
else
	if isempty(labels) 
		labels = repmat(char(255),m,1); % default label:char(255)
	else
		if size(labels,1) ~= m
			error('Wrong number of labels supplied')
		end
	end

	if ~isa(labels,'dataset')
		[nlab,labl] = renumlab(labels);
		c = max(nlab);
	else
		labl = getfeat(labels);
		[nl,labl] = renumlab(labl);
		c = size(labl,1);
		labels.d = labels.d(:,nl);
		nlab = labels;
	end

	if isempty(featlist) 
		featlist = [1:k]';
%		Allow more labels than features
%	else
%		if size(featlist,1) ~= k
%			error('Wrong number of feature labels supplied')
%		end
	end
	if ~isempty(lablist)
		[nl1,nl2,labll] = renumlab(labl,lablist);
		cc = max(nl2);
		if cc < c
			error('Labellist does not correspond to set of labels')
		end
	else
		nl2 = [];
		cc = c;
	end
%	if length(nl2) ~= size(labl,1)
%		prob = [];
%	end
	if ~isempty(prob)
		if prob == 0
			prob = ones(cc,1)/cc;
		end
		if ~isempty(nl2)
			if length(prob) ~= length(nl2)
				error('Wrong number of probabilities supplied')
			end
			pp = prob;
			prob = zeros(c,1);
			for i=1:c
				j = find(nl2==nl1(i));
				%if length(j) ~= 1
				%	error('Labellist does not correspond to set of labels')
				%end
				prob(i) = sum(pp(j));
			end
			prob = prob/sum(prob);
		end
	end
	if isempty(imheight)
		imheight = 0;
	end
	if imheight > 0 & imheight*round(k/imheight) ~= k
		error('Image height inconsistent with data feature size')
	end
	if imheight < 0 & imheight*round(m/imheight) ~= m
		error('Image height inconsistent with data size')
	end

	a.d = gdouble(+a);
	a.l = nlab;
	if ~isempty(prob)
		if any(prob > 1)
			error('Class prior probabilities should be less than 1')
		end
		if any(prob < 0)
			error('Class prior probabilities should be positive')
		end
		if abs(sum(prob)-1) > 1e-6
			warning('Class prior probabilities normalized to 1')
		end
		prob = prob/sum(prob);
	end

	a.p = prob(:);
	if iscell(featlist)
		a.f = char(featlist);
	else
		a.f = featlist;
	end
	a.ll = {labl};
	a.c = imheight;
	a.s = 0;

	nlab = class(a,'dataset');
	superiorto('double')
end
return
