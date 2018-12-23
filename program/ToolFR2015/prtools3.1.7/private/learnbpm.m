function [dw,db] = learnbpm(p,d,lr,mc,dw,db)
%LEARNBPM Backpropagation learning rule with momentum.
%	
%	[dW,dB] = LEARNBPM(P,D,LR,MC,dW,dB)
%	  P  - RxQ matrix of input vectors.
%	  D  - SxQ matrix of error vectors.
%	  lr - the learning rate.
%	  mc - momentum constant.
%	  dW - SxR weight change matrix.
%	  dB - Sx1 bias change vector (optional).
%	Returns:
%	  dW - a new weight change matrix.
%	  dB - a new bias change vector (optional).
%	
%	See also NNLEARN, BACKPROP, SIMFF, INITFF, TRAINBPX.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright (c) 1992-93 by the MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:25:05 $

if nargin < 5,error('Not enough input arguments'),end

x = (1-mc)*lr*d;
dw = mc*dw + x*p';
if nargout == 2
  [R,Q] = size(p);
  db = mc*db + x*ones(Q,1);
end
