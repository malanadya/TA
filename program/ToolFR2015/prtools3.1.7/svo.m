%SVO David's and Dick's Support Vector Optimizer
% 
% 	[v,J] = svo(K,nlab,C)
% 
% Low level routine that optimizes the set of support vectors for a 
% two class classification problem from a similarity matrix K of a 
% training set. The labels nlab should indicate the two classes by 
% +1 and -1. Optimization is done iteratively using a quadratic 
% programming
% 
% 	C - scalar for weighting the errors
% 	v - vector with weights of support vectors
% 	J - index vector pointing to the support vectors
% 
% See also svc


function [v,J] = svo(K,y,C,verbos)

if nargin < 4, verbos = 0; end
if nargin < 3, C = 1; end

c               = 1e+20;     % upperbound for v's
v_crit          = 1e-10;
negdef          = 0;         % for qp
normalize       = 1;

num_points = size(K,1);
v = zeros(1, num_points+1);

% D is defined as   D_ij = y_i*y_j*DotProduct(x_i,x_j)
% DotProduct(x_i,x_j) is given.

D = (y*y').*K;

% Make sure matrix K is semi-positive definite.
% If not, add epsilon*I with epsilon=10^i
i = -30;
while (pd_check (D + (10.0^i) * eye (num_points)) == 0)
  i = i + 1;
end
i=i+5;
D = D + (10.0^(i)) * eye(num_points);

D = [D                     zeros(num_points,1); .... 
     zeros(1,num_points)   1/C];


% Minimization procedure initialization:
% 'qp' minimizes:   0.5 x' K x + f' x
% subject to:       Ax <= b
% 
% Here: one constraint is coded into the lower
% bound of the solution (i.e., a(i) >= 0, eqn. 16), 
% the other is given in f: 
% Ax <= b with A = vector containing y(i)'s, 
% x = the solution to be found (a(i)'s) and
% b = 0 gives a'y = 0 (eqn. 17). So we set f to
% (-1 -1 ... -1)'.
%
% NB: Since we want to *maximize* eqn. 26,
%     we minimize its negative - that's why
%     f is negative.

f = [-ones(num_points, 1); 0];

% The first row in A is the equality constraint
% vy = 0. The second to last rows are the constraints
% given in eqn. 29: all v(i) should be smaller than
% delta....

A = [y'              0; ...
    eye(num_points) -ones(num_points, 1) ];
b = zeros (num_points + 1, 1);

% One of our constraints: each a(i) should be >= 0 (the
% lower bound, lb). The upper bound is an arbitrary
% number.

lb = zeros (num_points + 1, 1);
ub= [ C * ones(num_points + 1, 1)];

% Initial guess. This doesn't seem to have an
% enormous effect.


rand ('seed', sum( 100 * clock));
p = 0.5 * rand (num_points + 1, 1);

% Call the minimization routine. Note: this routine
%	has some built-in safety checks and returns []
% when it decides something is definitely wrong.
% 
% The last 1 in the call means that only the first
% constraint is an equality constraint. See 'qp'.

%  disp ('About to call qp')
if (exist('qld') == 3)
  v = qld (D, f, -A, b, lb, ub, p, 1)';
else
  disp('Warning: qld not found, using Matlab qp')
  v = qp (D, f, A, b, lb, ub, p, 1, verbos, negdef, normalize)';
end

if isempty(v)
  disp ('Mislukt...')
  v = pinv([K ones(num_points,1)])*y;
  v = v';
end
delta = v(num_points + 1);
v(num_points + 1) = [];

J=find(abs(v)>v_crit);
if length(J) == 0
	J = [1:length(v)]';
end
v=v(J)';

%Calculate the last parameter: b!
%Take support vectors which are *on* the boundary: v(i)<delta.
%Number them by limitv:
limit = find(v < delta-0.0001);
if isempty(limit)
  limit = 1:length(v);
end

nrlimit = length(limit);
bo = zeros(nrlimit,1);
%check each object on the border:
for i=1:nrlimit
  %calculate the f:
  f = 0;
  for k=1:length(v)
    f = f + y(J(k))*v(k)*K(J(k),J(limit(i)));
  end
  % and the bo:
  bo(i) = y(J(limit(i))) - f;
end

% voila:

v=[y(J).*v; mean(bo)];
return
