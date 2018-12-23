function n = purelin(n,b)
%PURELIN Linear transfer function.
%	
%	PURELIN(N)
%	  N - SxQ Matrix of net input (column) vectors.
%	Returns N.
%	
%	EXAMPLE: n = -10:0.1:10;
%	         a = purelin(n);
%	         plot(n,a)
%	
%	PURELIN(Z,B) ...Used when Batching.
%	  Z - SxQ Matrix of weighted input (column) vectors.
%	  B - Sx1 Bias (column) vector.
%	Returns values found by adding B to each column of Z.
%	
%	PURELIN('delta') returns name of delta function.
%	PURELIN('init') returns name of initialization function.
%	PURELIN('name') returns full name of this transfer function.
%	PURELIN('output') returns output range of this function.
%	
%	See also NNTRANS, SATLIN, SATLINS.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright (c) 1992-94 by The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:28:12 $

if nargin < 1, error('Not enough arguments.'); end

if isstr(n)
  if strcmp(lower(n),'delta')
    n = 'deltalin';
  elseif strcmp(lower(n),'init')
    n = 'rands';
  elseif strcmp(lower(n),'name')
    n = 'Linear';
  elseif strcmp(lower(n),'output')
    n = [-inf +inf];
  else
    error('Unrecognized property.')
  end
else
  if nargin==2
    [nr,nc] = size(n);
    n = n + b*ones(1,nc);
  end
end
