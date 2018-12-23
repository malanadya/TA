%GENDATP Parzen density data generation
% 
% 	B = gendatp(A,m,s)
% 
% Generation of m points using the Parzen estimate of the density of 
% the dataset A using a smoothing parameter s. Default s or s = 0: 
% maximum likelihood estimate from A using the routine parzenml.
% 
% 	B = gendatp(A,m,s,G)
% 
% Use G as the covariance matrix instead of the identy matrix for 
% generating data.
% 
% See also datasets, gendatk, gendatt

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function B = gendatp(A,m,s,G)
[ma,k] = size(A);
if nargin == 2, s = 0; end
if s == 0
	s = parzenml(A);
end
if nargin <= 3
	B = A(ceil(rand(m,1) * ma),:) + randn(m,k)*s;
elseif nargin == 4
	B = A(ceil(rand(m,1) * ma),:) + gauss(m,zeros(1,k),G)*s;
else
	error('wrong number of input arguments')
end
return
