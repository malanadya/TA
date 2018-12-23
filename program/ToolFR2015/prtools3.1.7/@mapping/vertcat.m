function w = vertcat(varargin)
%disp('mappping-vertcat')
w = varargin{1}; start = 2;
if nargin == 1, return; end
if isempty(w)
	w = varargin{2}; start = 3;
	if nargin == 2, return; end
end

[kw,cw] = size(w);
if ~strcmp(w.m,'parallel')
	if cw == 1 & size(w.l,1) == 2
		w.c = 2; cw = 2;
	end
	w = mapping('parallel',w,w.l,kw,cw,1);
	w.d = {w.d};
end
isc = ischar(w.l);
for i=start:length(varargin)
	v =  varargin{i};
	[kv,cv] = size(v);
	if cv == 1 & size(v.l,1) == 2
		v.c = 2; cv = 2;
	end
	w.d = [w.d {v}];
	w.k = w.k + v.k;
	w.l =  abs(str2mat(w.l,v.l));
end
w.c = size(w.l,1);
if isc, w.l = char(w.l); end
return
