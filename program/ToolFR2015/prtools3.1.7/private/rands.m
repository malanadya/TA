function [w,b] = rands(s,r)
%RANDS Symmetric random generator.
%	
%	[W,B] = RANDS(S,R)
%	  S - Number of rows (neurons).
%	  R - Number of columns (inputs).
%	Returns
%	  W - SxR (weight) matrix of values in [-1,+1].
%	  B - Sx1 (bias) vector of values in [-1,+1] (optional).
%	
%	See also NNRAND, RANDNR, RANDNC, NWLOG, NWTAN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright (c) 1992-94 by The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:28:29 $

if nargin < 2, error('Not enough arguments.'); end

% NUMBER OF INPUTS
[R,Q] = size(r);
if max(R,Q)>1, r = R; end

% CREATE WEIGHTS AND BIASES
w = 2*rand(s,r)-1;
if nargout==2
  b = 2*rand(s,1)-1;
end

