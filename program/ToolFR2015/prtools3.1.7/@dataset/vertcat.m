function a = vertcat(varargin)
%disp('dataset-vertcat')
a = varargin{1}; start = 2;
if length(varargin) == 1, return, end 
if isempty(a) | prod(size(a))==0
	a = varargin{2}; start = 3;
end
[ma,ka] = size(a);
if ~isa(a,'dataset')
	error('First argument should be dataset');
end
a = dataset(a);
str = isstr(a.ll{1});
aa = a.d;
%if a.s, aa = aa'; end
alab = a.ll{1}(a.l,:);
afeat = a.f;
aprob = a.p;
alabl = a.ll{1};
aimh  = a.c;
if aimh < 0; aimh = 0; end
for i=start:length(varargin)
	b = varargin{i};
	if ~isempty(b)
		[mb,kb] = size(b);
		if ka ~= kb
			error('datasets should have equal numbers of features');
		end
		if ~isa(b,'dataset') | ~isa(b.ll,'cell')
			b = dataset(b); 
		end
		aa = [aa; b.d];
		alab = abs(str2mat(alab,b.ll{1}(b.l,:)));
		alabl = abs(str2mat(alabl,b.ll{1}));
		if isempty(a.p) | isempty(b.p)
			aprob = [];
		else
			aprob = [aprob; b.p];
		end
	end
end

if str, alab = setstr(alab); alabl = setstr(alabl); end
a = dataset(aa,alab,afeat,aprob,alabl,aimh);
return
