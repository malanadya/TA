function c = subsref(a,s)
if isempty(s.subs{1}) | (length(s.subs)>1 & isempty(s.subs{2}))
	c = [];
	return
end
if length(s.subs) == 1
	if strcmp(s.subs{1},':')
		c = a.d(:);
	else
		c = a.d(s.subs{1});
	end
else
	[m,k] = size(a);
	imheight = a.c;
	if strcmp(s.subs{1},':')
		row = [1:m];
	else
		row = s.subs{1};
		if imheight < 0
			imheight = 0;
		end
	end
	if strcmp(s.subs{2},':')
		col = [1:k];
	else
		col = s.subs{2};
		if imheight > 0
			imheight = 0;
		end
	end
	c = a;
  	c.d = a.d(row(:),col);
	c.c = imheight;
	if a.s
		cr = col; col = row; row = cr;
	end
	c.f = a.f(col,:);
	if ~isa(a.ll,'cell')
		a = dataset(a);
	end
	if isa(a.l,'dataset')
		c.l.d = a.l.d(row,:);
		c.ll = a.ll;
	else
		[c.l,c.ll] = renumlab(a.ll{1}(a.l(row),:));
	end
	if ~isempty(a.p)
		[n1,n2] = renumlab(a.ll{1},c.ll);
		c.p = a.p(n2);
		c.p = c.p / sum(c.p);
	end
	if c.c > 0 & c.c*round(k/c.c) == k
		if c.c*round(k/c.c) ~= k
			c.c = 0;
		end
	elseif c.c < 0 & c.c*round(m/c.c) == m
		if c.c*round(m/c.c) ~= m
			c.c = 0;
		end
	end
	c.ll = {c.ll};
end
return
	
