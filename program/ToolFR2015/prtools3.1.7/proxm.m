%PROXM Proximity mapping
% 
% 	W = proxm(A,type,p,g)
% 
% Computation of the k*m proximity mapping (or kernel) defined by 
% the m*k dataset A. If B is a n*k dataset then B*W is the n*m 
% proximity matrix between B and A. The proximities are defined by 
% the following possible types: 
% 
% 	'polynomial'   | 'p': sign(a*b'+1).*(a*b'+1).^p
% 	'exponential'  | 'e': exp(-(||a-b||)/p)
% 	'radial_basis' | 'r': exp(-(||a-b||.^2)/(p*p))
% 	'sigmoid'      | 's': sigm((sign(a*b').*(a*b'))/p)
% 	'distance'     | 'd': ||a-b||.^p
% 
% In the polynomial case and p not integer D is computed by D = 
% sign(d)*abs(d).^p in order to avoid problems with negative inner 
% products d. The features of the objects in A and B may be weighted 
% by the weights in the vector g (default 1).
% 
% Default is the Euclidean distance: type = 'distance', p = 1
% 
% See also mappings, datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = proxm(A,type,s,g)
if nargin < 4, g = []; end
if nargin < 3 | isempty(s), s = 1; end
if nargin < 2 | isempty(type), type = 'd'; end
% if nargin < 1 | isempty(A)
% 	W = mapping('proxm',{type,s,g});
% 	return
% end

[m,k] = size(A);
A = dataset(A);
if isstr(type)
	W = mapping('proxm',A,getlab(A),k,m,1,{type,s,g});
	return
end

if ~isa(type,'mapping')
	error('Illegal arguments')
end

[B,lablist,t,kk,n,v,par] = mapping(type);
B = dataset(B);
type = par{1};
s = par{2};
g = par{3};

if k ~= kk, error('Matrices should have equal numbers of columns'); end
if ~isempty(g)
	if length(g) ~= k, error('Weight vector has wrong length'); end
	A = A.*(ones(m,1)*g(:)');
	B = B.*(ones(n,1)*g(:)');
end
if strcmp(type,'polynomial') | strcmp(type,'p')
	W = +(A*B'); 
	W = W + ones(m,n);
	if s ~= round(s)
		W = sign(W).*abs(W).^s;
	elseif s ~= 1
		W = W.^s;
	end
elseif strcmp(type,'sigmoid') | strcmp(type,'s')
	W = +(A*B'); 
	W = sigm(W/s);
else
	W = ones(m,1)*sum(B'.*B',1); 
	W = W  + sum(A'.*A',1)'*ones(1,n); 
	W = W -2 .* (+A)*(+B)';
	J = find(W<0);
	W(J) = zeros(size(J));
	if strcmp(type,'exponential') | strcmp(type,'e')
		
		W = exp(-sqrt(W)/s);
	elseif strcmp(type,'radial_basis') | strcmp(type,'r')
		W = exp(-W/(s*s));
	elseif strcmp(type,'distance') | strcmp(type,'d')
		if s ~= 2
			W = sqrt(W).^s;
		end
	else
		error('Unknown proximity type')
	end
end
if isa(A,'dataset') | isa(B,'dataset') 
	if isa(A,'dataset'); laba = getlab(A); else laba = [1:m]; end
	if isa(B,'dataset'); labb = getlab(B); else labb = [1:m]; end
	W = dataset(W,laba,labb);
end
