function [x,iter,history]= GPSR_BCB(y,A,tau)
	% Set the defaults for the optional parameters
	tolA = 0.01;
	maxiter = 10000;
	miniter = 5;
	alphamin = 1e-30;
	alphamax = 1e30;

	% Precompute A'*y since it'll be used a lot
	Aty = A'*y;
	
	dims = size(y,2);
	history = [];

	% Initialization
	xB = zeros(size(A,2),dims);%AT(zeros(size(y)));

	% initialize u and v
	uB = zeros(size(xB));%x.*(x >= 0);
	vB = zeros(size(xB));%-x.*(x <  0);

	% store given stopping criterion and threshold, because we're going 
	% to change them in the continuation procedure
	final_tolA = tolA;
	iter = ones(size(y,2),1);

	% Compute and store initial value of the objective function
	resid =  y - A*xB;

	tolA = final_tolA;
	alphaB = ones(1, dims);

	% Compute the initial gradient and the useful 
	% quantity resid_base
	resid_base = y - resid;

	% control variable for the outer loop and iteration counter
	keep_going = ones(size(y,2), 1);
	while sum(keep_going)

		% compute gradient
		tempB = A'*resid_base;

		termB  =  tempB - Aty;
		graduB =  termB + tau;
		gradvB = -termB + tau;

		% projection and computation of search direction vector
		ALPHA = repmat(alphaB, size(graduB,1), 1);
		duB = max(uB - ALPHA.*graduB, 0.0) - uB;
		dvB = max(vB - ALPHA.*gradvB, 0.0) - vB;
		dxB = duB-dvB;
		old_uB = uB; 
		old_vB = vB;

		% calculate useful matrix-vector product involving dx
		auvB = A*dxB;

		% Everything after this can be individualized
		for k = 1:dims
			
			if ~keep_going(k)
				continue
			end
			
			temp = tempB(:,k);
			term = termB(:,k);
			gradu = graduB(:,k);
			gradv = gradvB(:,k);
			du = duB(:,k);
			dv = dvB(:,k);
			old_u = old_uB(:,k);
			old_v = old_vB(:,k);
			auv = auvB(:,k);
			u = uB(:,k);
			v = vB(:,k);
			x = xB(:,k);
			alpha = alphaB(:,k);

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

			% ----- Core update ------
			resid_base(:,k) = resid_base(:,k) + lambda*auv; 
			uB(:,k) = u;
			vB(:,k) = v;
			xB(:,k) = x;
			alphaB(:,k) = alpha;
			
			history = [history x];

			% update iteration counts, store results and times
			iter(k) = iter(k) + 1;

			% compute the "LCP" stopping criterion - again based on the previous
			% iterate. Make it "relative" to the norm of x.
			w = [ min(gradu(:), old_u(:)); min(gradv(:), old_v(:)) ];
			criterionLCP = norm(w(:), inf);
			criterionLCP = criterionLCP / max([1.0e-6, norm(old_u(:),inf), norm(old_v(:),inf)]);
			keep_going(k) = (criterionLCP > tolA);

			% take no less than miniter... 
			if iter(k)<=miniter
				keep_going(k) = 1;
			elseif iter(k) > maxiter %and no more than maxiter iterations  
				keep_going(k) = 0;
			end
		end
	end % end of the main loop of the BB-QP algorithm
	
	x = xB;
end