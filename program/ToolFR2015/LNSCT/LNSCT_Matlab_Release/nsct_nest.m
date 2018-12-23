function nstd = nsct_nest(nrows, ncols, pfilt, dfilt, nlevs)
% NSCT_NEST  Estimate the noise standard deviation in the NSCT domain
%
%   nstd = pdfb_nest(nrows, ncols, pfilt, dfilt, nlevs)
%
% Used for NSCT denoising.  For an additive Gaussian white noise of zero
% mean and sigma standard deviation, the noise standard deviation in the
% NSCT domain (in vector form) is sigma * nstd.

% Number of interations
niter = 10;

% First run to get the size of the PDFB
x = randn(nrows, ncols);
y= nsctdec(x, nlevs, dfilt, pfilt );
[c, s] = nsct2vec(y);

nstd = zeros(1, length(c));
nlp = s(1, 3) * s(1, 4);	% number of lowpass coefficients
nstd(nlp+1:end) = nstd(nlp+1:end) + c(nlp+1:end).^2;

for k = 2:niter
    x = randn(nrows, ncols);
    y= nsctdec(x, nlevs, dfilt, pfilt );
    [c, s] = pdfb2vec(y);
    
    nstd(nlp+1:end) = nstd(nlp+1:end) + c(nlp+1:end).^2;
end

nstd = sqrt(nstd ./ (niter - 1));
