function n = normr(m)
%NORMR Normalize rows of matrix.
%	
%	NORMR(M)
%	  M - a matrix.
%	Returns a matrix the same size with each
%	row normalized to a vector length of 1.
%	
%	See also NORMC, PNORMC.

% Mark Beale, 1-31-92
% Copyright (c) 1992-94 by the MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:27:09 $

if nargin < 1,error('Not enough input arguments.'); end

[mr,mc]=size(m);
if (mc == 1)
  n = m ./ abs(m);
else
  n=sqrt(ones./(sum((m.*m)')))'*ones(1,mc).*m;
end
