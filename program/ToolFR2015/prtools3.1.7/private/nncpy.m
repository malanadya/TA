function b = nncpy(m,n)
%NNCPY Make copies of a matrix.
%	
%	*WARNING*: This function is undocumented as it may be altered
%	at any time in the future without warning.

%	NNCPY copies matrices directly as appossed to interleaving
%   the copies as done by COPYINT.
%
% NNCPY(M,N)
%   M - Matrix.
%   N - Number of copies to make.
% Returns:
%   Matrix = [M M ...] where M appears N times.
%
% EXAMPLE: M = [1 2; 3 4; 5 6];
%          n = 3;
%          X = nncpy(M,n)
%
% SEE ALSO: nncpyi, nncpyd

% Mark Beale, 12-15-93
% Copyright (c) 1992-94 by the MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:26:08 $

[mr,mc] = size(m);
b = zeros(mr,mc*n);
ind = 1:mc;
for i=[0:(n-1)]*mc
  b(:,ind+i) = m;
end
