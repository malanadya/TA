function w = randnr(s,r)
%RANDNR Normalized row random generator.
%	
%	RANDNR(S,R)
%	  S - Size of neuron layer (# of rows).
%	  R - Number of inputs (# of columns).
%	Returns an SxR weight matrix.
%	
%	NOTE - Row vector directions may not be uniformly distributed.
%	
%	See also NNRAND, RANDNC.

% Mark Beale, 1-31-92
% Copyright (c) 1992-94 by the MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:28:26 $

if nargin ~= 2
  error('Wrong number of arguments.');
end

w = normr(rands(s,r));
