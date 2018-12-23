function d = mtimes(a,b)
[ca,ra] = size(a);
[cb,rb] = size(b);
if isa(a,'mapping') & isa(b,'mapping')
	
	if istrained(a) & iscombiner(b)
			% combiners know what to do with trained mappings
		d = fevalw(b,a);
		return
		
	elseif strcmp(a.m,'affine') & ~a.s & strcmp(b.m,'affine') & ~b.s
			% combine sequence of affine mappings
		d = b;
		d.d = a.d(1:end-1,:) * b.d(1:end-1,:);
		d.d = [d.d; a.d(end,:)*b.d(1:end-1,:) + b.d(end,:)];
		d.k = a.k;
		d.v = a.v*b.v;
		return
		
	elseif strcmp(a.m,'affine') & ~a.s & strcmp(b.m,'normalize')
			% combine affine mapping and normalization (shift and scale)
		d = b;
		d.d = a.d(1:end-1,:) * diag(b.d{2});
		d.d = [d.d; (a.d(end,:)  - b.d{1})*diag(b.d{2})];
		d.k = a.k;
		d.v = a.v*b.v;
		d.m = 'affine';
		return
		
	elseif strcmp(a.m,'normalize') & strcmp(b.m,'affine') & ~b.s
			% combine normalization (shift and scale) with affine mapping 
		d = b;
		d.d = diag(a.d{2}) * b.d(1:end-1,:);
		d.d = [d.d; a.d{1}*b.d(1:end-1,:) + b.d(end,:)];
		d.k = a.k;
		d.v = a.v*b.v;
		return
		
			% see mapping.m for rb = -1 trick in case of normm
			% which converts 1d datasets to 2d datasets to enable
			% normalization to feature vector length one
	elseif rb == -1 & ra == 1
		rd = 2;
			% handle fixed mappings, having unknown size (ra, rb = 0)
	elseif rb == -1 & ra == 0
		rd = -1;
	elseif rb == -1
		rd = ra;
	elseif rb == 0
		rd = 0;
			% default: output size equals output size of output mapping
	else
		rd = rb;
	end
			% this is the sequential combination of mappings
			% the two mappings are stored in a cell-array
			% the labels are those of the output mapping
			% the input size is that of the input mapping
			% the output size is usually that of the output mapping
	d = mapping('sequential',{a,b},getlab(b),ca,rd,1);
	return
	
			% handle (mapping * data) as (data * mapping)
			% this is irregular, but allows for constructions
			% as a * ldc * b * testd (training by a, testing by b)
elseif isa(a,'mapping') & (isa(b,'dataset') | isa(b,'double'))
	d = [b*a];
	return
	
			% data * mapping will be handled below
elseif (isa(a,'dataset') | isa(a,'double')) & isa(b,'mapping')
	;
else
	error('Operation undefined')
end

% **********************************************************************

		% Now we go for data * mapping
		
% **********************************************************************

			% don't know what to do with empty dataset 
			% produce empty mapping, unity mapping ??
			% for the moment we don't support it
% if isempty(a), error('Empty dataset * mapping is not supported'); end

			% handle scalar * mapping by .* (see times.m)
if isa(a,'double') & ra == 1 & ca == 1, d = a.*b; return; end

			% check inner sizes in case of trained mapping
if istrained(b) & ra ~= cb & cb~=0, error('Dimensions of dataset and mapping do not match'); end

			% retrieve mapping parameters
[w,classlist,map,k,c,vscale,pars] = mapping(b);

			% remember whether we have a dataset (or doubles)
isda = isa(a,'dataset');

			% retrieve data details
			% set imheight to 0 in case of object images
			% as image interpretation is lost by mapping
if isda
	[nlab,lablist,m,ka,ca,prob,featlist,imheight] = dataset(a);
	if imheight > 0 & imheight*round(ka/imheight) == ka, imheight = 0; end
else
	[m,ka] = size(a);
end

			% another check on sizes
if k ~=0 & k ~= ka
	error('Feature size of data does not match input size of map');
end

			% other = 1: output feature labels are set on another place
			% other = 0: standard handling of output feature labels
			%            by using classlist of the mapping
other = 0;

		% handling of all general mapping procedures and combinations
switch map
			% stacked mappings : a*[w1 w2 w3 ...] = [a*w1 a*w2 a*w3 ...]
case 'stacked'
	d =[];
	for j = 1:length(w)
		d = [d a*w{j}]; 
	end
			% parallel mappings : a*[w1; w2; w3..] = [a1*w1 a2*w2 a3*w3 ...]
			% in which a1, a2, a3 ... are feature subsets of a
			% feature size are determined by input sizes of w1, w2, w3, ...
case 'parallel'
	d =[]; n = 0;
	for j = 1:length(w)
		sz = size(w{j},1); N = [n+1:n+sz]; n = n +sz;
		d = [d a(:,N)*w{j}]; 
	end
			% sequential mappings w1*w2*w3*... are handled pair by pair
case 'sequential'
	d =a*w{1};
	if isuntrained(w{2})
			% if both mappings are untrained, they should be
			% trained properly and combined.
			% As a*w1 is a trained mapping, the training data for w2
			% is a*(a*w1), so we have:
			% a*(w1*w2) = (a*w1) * (a*(a*w1)*w2)
		if isuntrained(w{1})
			d = d*(a*d*w{2}); 

			% if w{1} does not need training, d = a*w{1} is directly
			% the training data for w{2}
		else
			d = w{1}*(d*w{2});
		end
			% straightforward if both don't need training
	else
		d = d*w{2}; 
	end
			% if the combiner has no feature labels, they cann't be used
	if isempty(classlist), other = 1; end
   
case 'affine'		% linear map
	d = [a,ones(m,1)]*w;
			% feature images (imheight<0) are preserved as image
			% (bit transformed as the space is rotated),
			% but object images are lost, imheight should already be 0
			% if the transform contains images they can be taken over
			% in case of no feature images.
	if pars < 0 & isda & imheight >= 0, imheight = -pars; end
	if pars < 0 & ~isda, imheight = -pars; isda = 1; end
   
case 'quadratic'	% quadratic map
	d = sum((a*w{3}).*a,2) + a*w{2} + ones(m,1)*w{1};
	
case 'support-vector'	% support vector mapping and classifier
	if isempty(w{1})
		d = a*proxm(w{2},pars{1},pars{2});
	else
		d = (a-ones(m,1)*w{1})*proxm(w{2},pars{1},pars{2});
	end
	if length(w) > 2
		d = [d ones(m,1)] * w{3};
	end
	
case 'neurnet'	% feed forward network
	n = length(pars)-1;			% number of layers
	d = a;
	for j = 1:n-1
		r = pars(j);			% number of inputs
		q = pars(1+j);			% number of outputs
		V = reshape(w(1:(r+1)*q),r+1,q);
		d = sigm([d,ones(m,1)]*V);
		w(1:(r+1)*q) = [];%per CPU
        %w=w(1+(r+1)*q:length(w));%per jackets
	end
	r = pars(n);				% number of inputs
	q = pars(n+1);				% number of outputs
	d = [d,ones(m,1)] * reshape(w(1:(r+1)*q),r+1,q);
	
case 'exp'	% exponent
	d = exp(a);
	
case 'nexp'	% negative exponent
	d = exp(-a);
	
case 'log'	% logarithm
	d = log(a);
	
case 'featsel'	% feature selection
	d = a(:,w);
	
case 'normalize'	% normalization (shift and scaling, see cmapm)
	d = (a - ones(m,1)*w{1});
	if m > k % necessary switch for handling large feature sizes
		for j=1:k
			d(:,j) = d(:,j)*w{2}(j);
		end
	else
		for i=1:m
			d(i,:) = d(i,:).*w{2};
		end
	end
	if w{3}		% clip if necessary (see scalem)
		jm = find(+d < 0);
		jx = find(+d > 1);
		d(jm) = zeros(size(jm));
		d(jx) = ones(size(jx));
	end
	
case 'polynomial'	% polynomial features
	[n,k] = size(w);
	d = zeros(m,n); 
	for i = 1:n
	    d(:,i) = prod((a .^ (ones(m,1)*w(i,:))),2); 
	end
	featlist = [];
			% here we handle all user defined mappings
			% by calling the appropriate routine
otherwise
			% untrained mappings should generate a mapping
	if isuntrained(b) | iscombiner(b) % untrained classifiers and mappings
		d = fevalw(b,a);
			% set the classifier bit if it was set in the untrained mapping
		if isa(d,'mapping'), d = setclass(d,isclassifier(b)); end
		return 				% we are ready
			% other mappings should generate a dataset
	else
		if isfixed(b)
			d = feval(map,a);
		else
			d = feval(map,a,b);
		end
		other = 1;	% classlist should be handled by the user
	end
end

	% handle final details in case of no mapping

if ~isa(d,'mapping')

			% scaling
	if length(vscale) == 1
		if vscale ~= 1, d = vscale*d; end
	elseif length(vscale) == c
		d = d .* repmat(vscale,m,1);
	else
		error('Mapping has illegal scaling size')
	end

			% correct for two-class outcomes if desired
	if size(d,2) == 1 & c == 2
		d = [d -d]; other = 0;
	end

			% Set classlist as feature labels if necessary
	if ~other
			% preserve object labels and imheight if input was dataset
		if isda
			d = dataset(d,getlab(a),classlist,[],[],imheight);
		else
			d = dataset(d,[],classlist);
		end	
	end

			% Make probs and normalize in case of classifier
	if isclassifier(b)
			% this extends the classification data with a rejectvalue
			% there no tools, yet, to optimize this value, nor to
			% use it during testing
		r = getreject(b);
		if isfinite(r)
			d = [d dataset(repmat(r,m,1),[],NaN)];
		end
		d = sigm(d);
		d = normm(d);
	end
	
end
return

function d = fevalw(v,a)
%FEVALW calls the user routine for evaluating the data a by the mapping v
[w,cl,map] = mapping(v);
			% combiners and fixed mappings have stored their
			% information different as a consequence of their
			% mapping statement. 
if (iscombiner(v) | isfixed(v))
	w = cl;
end
			% user has stored in w the parameter values for the desired call
n = length(w);
			% no parameters
if n == 0 | (n == 1 & isempty(w))
	d = feval(map,a);
			% scalar parameter not in cell
elseif ~isa(w,'cell')
	d = feval(map,a,w);
			% parameters stored in cell-array
elseif n == 1
	d = feval(map,a,w{1});
elseif n == 2
	d = feval(map,a,w{1},w{2});
elseif n == 3
	d = feval(map,a,w{1},w{2},w{3});
elseif n == 4
	d = feval(map,a,w{1},w{2},w{3},w{4});
elseif n == 5
	d = feval(map,a,w{1},w{2},w{3},w{4},w{5});
elseif n == 6
	d = feval(map,a,w{1},w{2},w{3},w{4},w{5},w{6});
else
	error(['More than expected arguments for ' map '. Fix @mapping/mtimes'])
end
