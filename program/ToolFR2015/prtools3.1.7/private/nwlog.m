function [w,b] = nwlog(s,p,z)
%NWLOG Nguyen-Widrow random generator for LOGSIG neurons.
%	
%	[W,B] = NWLOG(S,P)
%	  S - Number of neurons in layer.
%	  P - Rx2 matrix of input value ranges.
%	Returns:
%	  W - new SxR weight matrix.
%	  B - new Sx1 bias vector.
%	
%	IMPORTANT: Each ith row of P must contain expected
%	  min and max values for the ith input.
%	
%	EXAMPLE: [w,b] = nwlog([-5 5; 0 1],4)
%	
%	See also NNRAND, LOGSIG, NWTAN.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB.
% Copyright (c) 1992-94 by the MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:27:15 $

if nargin < 2,error('Not enough arguments.'); end
if nargout < 2, error('Not enough output arguments.'); end

% BACKWARD COMPATIBILITY FOR NNT 1.0
% Convert NWLOG(S,R,P) -> NWLOG(S,P)
if nargin == 3
  p = z;
end
% Convert NWLOG(S,R) -> NWLOG(S,P)
if nargin == 2 & max(size(p)) == 1
  p = ones(p,1) * [0 1];
end

[r,q] = size(p);
pmin = min(p')';
pmax = max(p')';

magw = 2.8*s^(1/r);
w = magw*randnr(s,r);
b = magw*rands(s,1);

rng = pmax-pmin;
mid = 0.5*(pmin+pmax);
w = 2*w./(ones(s,1)*rng');
b = b - w*mid;
