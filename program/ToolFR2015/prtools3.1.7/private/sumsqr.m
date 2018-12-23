function s = sumsqr(a)
%SUMSQR Sum squared elements of matrix.
%	
%	SUMSQR(A)
%	  A - a matrix.
%	Returns the sum of squared elements in A.

% Mark Beale, 1-31-92
% Copyright (c) 1992-94 by the MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:29:23 $

if nargin < 1,error('Not enough input arguments.');end

s = sum(sum(a.*a));
