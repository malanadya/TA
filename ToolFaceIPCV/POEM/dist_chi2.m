% Chi^2 histogram distance. A,B are matrices of example data
% vectors, one per column. The distance is sum_i
% (u_i-v_i)^2/(u_i+v_i+epsilon). The output distance matrix is
% (#examples in A)x(#examples in B)

function D = dist_chi2(A,B,epsilon)
if nargin<3, epsilon=1e-100; end
%fprintf('\n *** calculating CHI^2 histogram distance ');
D= sum((A(:)-B(:)).^2./(A(:)+B(:)+epsilon));
