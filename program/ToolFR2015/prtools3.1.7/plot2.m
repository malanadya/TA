%PLOT2 Plot row 1 against row 2
% 
% 	plot2(x,s)
% 
% Plot x(1,:) against x(2,:) with plotstring s. plot2 returns the 
% returns of plot. Defaults s = 'b-'. This command is useful for 
% plotting roc-curves and reject curves.
% 
% See also roc, reject

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function V = plot2(x,s)
if nargin == 1, s='b-'; end
[n,k] = size(x);
VV = [];
m = floor(n/2);
if size(s,1) == 1
	s = repmat(s,m,1);
elseif size(s,1) ~= m
	error('Wrong number of plot strings');
end
h = ishold;
for i=1:floor(n/2);
	v = plot(x(2*i-1,:),x(2*i,:),char(s(i,:)));
	hold on;
	VV = [VV;v];
end
%axis equal
axis([0 1 0 1])
if ~h hold off; end
if nargout == 1, V = VV; end
