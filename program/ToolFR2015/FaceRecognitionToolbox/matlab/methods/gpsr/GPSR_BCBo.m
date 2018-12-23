function [x]= GPSR_BCB(y,A,tau)
% Set the defaults for the optional parameters
tolA = 0.01;
maxiter = 10000;
miniter = 5;
alphamin = 1e-30;
alphamax = 1e30;

% Precompute A'*y since it'll be used a lot
Aty = A'*y;

% Initialization
x = zeros(size(A,2),size(y,2));%AT(zeros(size(y)));

% initialize u and v
u = zeros(size(x));%x.*(x >= 0);
v = zeros(size(x));%-x.*(x <  0);

% store given stopping criterion and threshold, because we're going 
% to change them in the continuation procedure
final_tolA = tolA;
iter = 1;

% Compute and store initial value of the objective function
resid =  y - A*x;

tolA = final_tolA;
alpha = 1.0;

% Compute the initial gradient and the useful 
% quantity resid_base
resid_base = y - resid;

% control variable for the outer loop and iteration counter
keep_going = 1;
while keep_going

  % compute gradient
  temp = A'*resid_base;

  term  =  temp - Aty;
  gradu =  term + tau;
  gradv = -term + tau;

  % projection and computation of search direction vector
  du = max(u - alpha*gradu, 0.0) - u;
  dv = max(v - alpha*gradv, 0.0) - v;
  dx = du-dv;
  old_u = u; 
  old_v = v;

  % calculate useful matrix-vector product involving dx
  auv = A*dx;
  dGd = auv(:)'*auv(:);

    % monotone variant: calculate minimizer along the direction (du,dv)
    lambda0 = - (gradu(:)'*du(:) + gradv(:)'*dv(:))/(realmin+dGd);
    if lambda0 < 0
      fprintf(' ERROR: lambda0 = %10.3e negative. Quit\n', lambda0);
      return;
    end
    lambda = min(lambda0,1);
    
  u = old_u + lambda * du;
  v = old_v + lambda * dv;
  uvmin = min(u,v);
  u = u - uvmin; 
  v = v - uvmin; 
  x = u - v;

  % compute new alpha
  dd  = du(:)'*du(:) + dv(:)'*dv(:);  
  if dGd <= 0
    % something wrong if we get to here
    fprintf(1,' dGd=%12.4e, nonpositive curvature detected\n', dGd);
    alpha = alphamax;
  else
    alpha = min(alphamax,max(alphamin,dd/dGd));
  end
  resid_base = resid_base + lambda*auv; 

  % update iteration counts, store results and times
  iter = iter + 1;

  % compute the "LCP" stopping criterion - again based on the previous
  % iterate. Make it "relative" to the norm of x.
  w = [ min(gradu(:), old_u(:)); min(gradv(:), old_v(:)) ];
  criterionLCP = norm(w(:), inf);
  criterionLCP = criterionLCP / max([1.0e-6, norm(old_u(:),inf), norm(old_v(:),inf)]);
  keep_going = (criterionLCP > tolA);

  % take no less than miniter... 
  if iter<=miniter
      keep_going = 1;
  elseif iter > maxiter %and no more than maxiter iterations  
        keep_going = 0;
  end

end % end of the main loop of the BB-QP algorithm
end