function [c, s] = nsct2vec(y)
% PDFB2VEC   Convert the output of the NSCT into a vector form
%
%       [c, s] = nsct2vec(y)
%
% Input:
%   y:  an output of the NSCT
%
% Output:
%   c:  1-D vector that contains all NSCT coefficients
%   s:  structure of NSCT output, which is a four-column matrix.  Each row
%       of s corresponds to one subband y{l}{d} from y, in which the first two
%       entries are layer index l and direction index d and the last two
%       entries record the size of y{l}{d}.
%
% See also:	VEC2NSCT

n = length(y);

% Save the structure of y into s
s(1, :) = [1, 1, size(y{1})];

% Used for row index of s
ind = 1;

for l = 2:n
    nd = length(y{l});
    
    for d = 1:nd
        s(ind + d, :) = [l, d, size(y{l}{d})];
    end
    
    ind = ind + nd;
end

% The total number of PDFB coefficients
nc = sum(prod(s(:, 3:4), 2));

% Assign the coefficients to the vector c
c = zeros(1, nc);

% Variable that keep the current position
pos = prod(size(y{1}));

% Lowpass subband
c(1:pos) = y{1}(:);

% Bandpass subbands
for l = 2:n    
    for d = 1:length(y{l})
        ss = prod(size(y{l}{d}));
        c(pos+[1:ss]) = y{l}{d}(:);
        pos = pos + ss;
    end
end