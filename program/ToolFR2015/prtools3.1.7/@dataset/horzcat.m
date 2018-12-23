function a = horzcat(varargin)
%disp('dataset-horzcat')
a = varargin{1}; start = 2;
if nargin == 1, return; end
% if isempty(a) | prod(size(a))==0
% 	a = varargin{2}; start = 3;
% end
[ma,ka] = size(a);
if ~isa(a,'dataset')
	error('First argument should be dataset');
end
a.f = a.f(1:ka,:);
isc = ischar(a.f);
for i=start:length(varargin)
	b = varargin{i};
	[mb,kb] = size(b);
	if ma ~= mb
		error('datasets should have equal numbers of objects');
	end
	if isa(b,'dataset')
		a.d = [a.d  b.d];
		a.f = abs(str2mat(a.f,b.f(1:kb,:)));
	else
		a.d = [a.d  b];
		a.f = abs(str2mat(a.f,ones(kb,0)*''));
	end
end
if isc, a.f = char(a.f); end
return
