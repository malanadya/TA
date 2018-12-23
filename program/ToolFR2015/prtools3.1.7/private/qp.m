function [X,lambda,how]=qp(H,f,A,B,vlb,vub,X,neqcstr,verbosity,negdef,normalize)
%QP	Quadratic programming. 
%	X=QP(H,f,A,b) solves the quadratic programming problem:
%
%            min 0.5*x'Hx + f'x   subject to:  Ax <= b 
%             x    
%
%       [x,LAMBDA]=QP(H,f,A,b) returns the set of Lagrangian multipliers,
%       LAMBDA, at the solution.
%
%       X=QP(H,f,A,b,VLB,VUB) defines a set of lower and upper
%       bounds on the design variables, X, so that the solution  
%       is always in the range VLB < X < VUB.
%
%       X=QP(H,f,A,b,VLB,VUB,X0) sets the initial starting point to X0.
%
%       X=QP(H,f,A,b,VLB,VUB,X0,N) indicates that the first N constraints defined
%       by A and b are equality constraints.
%
%       QP produces warning messages when the solution is either unbounded
%       or infeasible. Warning messages can be turned off with the calling
%       syntax: X=QP(H,f,A,b,VLB,VUB,X0,N,-1).

%	Copyright (c) 1990-94 by The MathWorks, Inc.
%	$Revision: 1.22 $  $Date: 1994/01/25 18:16:56 $
%	Andy Grace 7-9-90.


% Handle missing arguments
if nargin < 11, normalize = 1;
	if nargin <	10, negdef = 0; 
		if nargin< 9, verbosity = []; 
			if nargin< 8, neqcstr=[]; 
				if nargin < 7, X=[]; 
					if nargin<6, vub=[]; 
						if nargin<5, vlb=[];
end, end, end, end, end, end, end
[ncstr,nvars]=size(A);
nvars = length(f); % In case A is empty
if ~length(verbosity), verbosity = 0; end
if ~length(neqcstr), neqcstr = 0; end
if ~length(X), X=zeros(nvars,1); end

% !DR1 - Some built-in safety. If the number of iterations
%        grows too large, or if the condition of a certain
%        matrix does not change, we know nothing good will
%        come of it, so we just return [].
maxiterations	= 50000;
iteration 		=  0;
prev_rcond		= -1;

f=f(:);
B=B(:);

simplex_iter = 0;
if  norm(H,'inf')==0 | ~length(H), H=0; is_qp=0; else, is_qp=~negdef; end
how = 'ok'; 

normf = 1;
if normalize > 0
	if ~is_qp
		normf = norm(f);
		f = f./normf;
	end
end

% Handle bounds as linear constraints
lenvlb=length(vlb);
if lenvlb > 0     
	A=[A;-eye(lenvlb,nvars)];
	B=[B;-vlb(:)];
end
lenvub=length(vub);
if lenvub>0
	A=[A;eye(lenvub,nvars)];
	B=[B;vub(:)];
end 
ncstr=ncstr+lenvlb+lenvub;

errcstr = 100*sqrt(eps)*norm(A); 
% Used for determining threshold for whether a direction will violate
% a constraint.
normA = ones(ncstr,1);
if normalize > 0 
	for i=1:ncstr
		n = norm(A(i,:));
		if (n ~= 0)
			A(i,:) = A(i,:)/n;
			B(i) = B(i)/n;
			normA(i,1) = n;
		end
	end
else 
	normA = ones(ncstr,1);
end
errnorm = 0.01*sqrt(eps); 

lambda=zeros(ncstr,1);
aix=lambda;
ACTCNT=0;
ACTSET=[];
ACTIND=0;
CIND=1;
eqix = 1:neqcstr; 
%------------EQUALITY CONSTRAINTS---------------------------
Q = zeros(nvars,nvars);
R = [];
if neqcstr>0
	aix(eqix)=ones(neqcstr,1);
	ACTSET=A(eqix,:);
	ACTIND=eqix;
	ACTCNT=neqcstr;
	if ACTCNT >= nvars - 1, simplex_iter = 1; end
	CIND=neqcstr+1;
	[Q,R] = qr(ACTSET');
	if max(abs(A(eqix,:)*X-B(eqix)))>1e-10 
		X = ACTSET\B(eqix);
		% X2 = Q*(R'\B(eqix)); does not work here !
	end
	%	Z=null(ACTSET);
	[m,n]=size(ACTSET);
	Z = Q(:,m+1:n);
	err = 0; 
	if neqcstr > nvars 
		err = max(abs(A(eqix,:)*X-B(eqix)));
		if (err > 1e-8) 
			how='infeasible'; 
			if verbosity > -1
				disp('Warning: The equality constraints are overly stringent;')
				disp('         there is no feasible solution.') 
			end
		end
		actlambda = -R\(Q'*(H*X+f)); 
		lambda(eqix) = normf * (actlambda ./normA(eqix));
		return
	end
	if ~length(Z) 
		actlambda = -R\(Q'*(H*X+f)); 
		lambda(eqix) = normf * (actlambda./normA(eqix));
		if (max(A*X-B) > 1e-8)
			how = 'infeasible';
			disp('Warning: The constraints or bounds are overly stringent;')
			disp('         there is no feasible solution.') 
			disp('         Equality constraints have been met.')
		end
		return
	end
% Check whether in Phase 1 of feasibility point finding. 
	if (verbosity == -2)
		cstr = A*X-B; 
		mc=max(cstr(neqcstr+1:ncstr));
		if (mc > 0)
			X(nvars) = mc + 1;
		end
	end
else
	Z=1;
end

% Find Initial Feasible Solution
cstr = A*X-B;
mc=max(cstr(neqcstr+1:ncstr));
if mc>eps
	A2=[[A;zeros(1,nvars)],[zeros(neqcstr,1);-ones(ncstr+1-neqcstr,1)]];
	[XS,lambdas]=qp([],[zeros(nvars,1);1],A2,[B;1e-5],[],[],[X;mc+1],neqcstr,-2,0,-1);
	X=XS(1:nvars);
	cstr=A*X-B;
	if XS(nvars+1)>eps 
		if XS(nvars+1)>1e-8 
			how='infeasible';
			if verbosity > -1
				disp('Warning: The constraints are overly stringent;')
				disp('         there is no feasible solution.')
			end
		else
			how = 'overly constrained';
		end
		lambda = normf * (lambdas(1:ncstr)./normA);
		return
	end
end

if (is_qp)
	gf=H*X+f;
	SD=-Z*((Z'*H*Z)\(Z'*gf));
% Check for -ve definite problems:
%  if SD'*gf>0, is_qp = 0; SD=-SD; end
else
	gf = f;
	SD=-Z*Z'*gf;
	if norm(SD) < 1e-10 & neqcstr
		% This happens when equality constraint is perpendicular
		% to objective function f.x.
		actlambda = -R\(Q'*(H*X+f)); 
		lambda(eqix) = normf * (actlambda ./ normA(eqix));
		return;
	end
end
% Sometimes the search direction goes to zero in negative
% definite problems when the initial feasible point rests on
% the top of the quadratic function. In this case we can move in
% any direction to get an improvement in the function so try 
% a random direction.
if negdef
	if norm(SD) < sqrt(eps)
		SD = -Z*Z'*(rand(nvars,1) - 0.5);
	end
end
oldind = 0; 


t=zeros(10,2);
tt = zeros(10,1);

% The maximum number of iterations for a simplex type method is:
%maxiters = prod(1:ncstr)/(prod(1:nvars)*prod(1:max(1,ncstr-nvars)))
%ncstr
%nvars

%--------------Main Routine-------------------
while 1
% Find distance we can move in search direction SD before a 
% constraint is violated.
	% Gradient with respect to search direction.
	GSD=A*SD;

	% Note: we consider only constraints whose gradients are greater
	% than some threshold. If we considered all gradients greater than 
	% zero then it might be possible to add a constraint which would lead to
	% a singular (rank deficient) working set. The gradient (GSD) of such
	% a constraint in the direction of search would be very close to zero.
	indf = find((GSD > errnorm * norm(SD))  &  ~aix);

	if ~length(indf)
		STEPMIN=1e16;
	else
		dist = abs(cstr(indf)./GSD(indf));
		[STEPMIN,ind2] =  min(dist);
		ind2 = find(dist == STEPMIN);
% Bland's rule for anti-cycling: if there is more than one blocking constraint
% then add the one with the smallest index.
		ind=indf(min(ind2));
% Non-cycling rule:
		% ind = indf(ind2(1));
	end
%------------------QP-------------
	if (is_qp) 
% If STEPMIN is 1 then this is the exact distance to the solution.
		if STEPMIN>=1
			X=X+SD;
			if ACTCNT>0
				if ACTCNT>=nvars-1 & CIND <= size(ACTSET,1)
				CIND
				size(ACTSET)
				size(ACTIND)
					ACTSET(CIND,:)=[];ACTIND(CIND)=[]; 
				end
				
				rlambda = -R\(Q'*(H*X+f));
				actlambda = rlambda;
				actlambda(eqix) = abs(rlambda(eqix));
				indlam = find(actlambda < 0);
				if (~length(indlam)) 
					lambda(ACTIND) = normf * (rlambda./normA(ACTIND));
					return
				end
% Remove constraint
				lind = find(ACTIND == min(ACTIND(indlam)));
				lind=lind(1);
				ACTSET(lind,:) = [];
				aix(ACTIND(lind)) = 0;
				[Q,R]=qrdelete(Q,R,lind);
				ACTIND(lind) = [];
				ACTCNT = ACTCNT - 2;
				simplex_iter = 0;
				ind = 0;
			else
				return
			end
		else
			X=X+STEPMIN*SD;
		end
		% Calculate gradient w.r.t objective at this point
		gf=H*X+f;
	else 
		% Unbounded Solution
		if ~length(indf) | ~finite(STEPMIN)
			if norm(SD) > errnorm
				if normalize < 0
					STEPMIN=abs((X(nvars)+1e-5)/(SD(nvars)+eps));
				else 
					STEPMIN = 1e16;
				end
				X=X+STEPMIN*SD;
				how='unbounded'; 
			else
				how = 'ill posed';
			end
			if verbosity > -1
				if norm(SD) > errnorm
					disp('Warning: The solution is unbounded and at infinity;')
					disp('         the constraints are not restrictive enough.') 
				else
					disp('Warning: The search direction is close to zero; the problem is ill posed.')
					disp('         The gradient of the objective function may be zero')
					disp('         or the problem may be badly conditioned.')
				end
			end
			return
		else 
			X=X+STEPMIN*SD;
		end
	end %if (qp)

% Update X and calculate constraints
	cstr = A*X-B;
	cstr(eqix) = abs(cstr(eqix));
% Check no constraint is violated
	if normalize < 0 
		if X(nvars,1) < eps
			return;
		end
	end
			
	if max(cstr) > 1e5 * errnorm
		if max(cstr) > norm(X) * errnorm 
			if verbosity > -1
				disp('Warning: The problem is badly conditioned;')
				disp('         the solution is not reliable') 
				verbosity = -1;
% !DR1
X=[];
return
% !DR1
			end
			how='unreliable'; 
			if 0
				X=X-STEPMIN*SD;
				return
			end
		end
	end


% Sometimes the search direction goes to zero in negative
% definite problems when the current point rests on
% the top of the quadratic function. In this case we can move in
% any direction to get an improvement in the function so 
% foil search direction by giving a random gradient.
	if negdef
		if norm(gf) < sqrt(eps)
			gf = randn(nvars,1);
		end
	end
	if ind
		aix(ind)=1;
		ACTSET(CIND,:)=A(ind,:);
		ACTIND(CIND)=ind;
		[m,n]=size(ACTSET);
		[Q,R] = qrinsert(Q,R,CIND,A(ind,:)');
	end
	if oldind 
		aix(oldind) = 0; 
	end
	if ~simplex_iter
		% Z = null(ACTSET);
		[m,n]=size(ACTSET);
		Z = Q(:,m+1:n);
		ACTCNT=ACTCNT+1;
		if ACTCNT == nvars - 1, simplex_iter = 1; end
		CIND=ACTCNT+1;
		oldind = 0; 
	else
		rlambda = -R\(Q'*gf);
		if rlambda(1) == -Inf
			fprintf('         Working set is singular; results may still be reliable.\n');
			[m,n] = size(ACTSET);
			rlambda = -(ACTSET + sqrt(eps)*randn(m,n))'\gf;
		end
		actlambda = rlambda;
		actlambda(eqix)=abs(actlambda(eqix));
		indlam = find(actlambda<0);
		if length(indlam)
			if STEPMIN > errnorm
				% If there is no chance of cycling then pick the constraint which causes
				% the biggest reduction in the cost function. i.e the constraint with
				% the most negative Lagrangian multiplier. Since the constraints
				% are normalized this may result in less iterations.
				[minl,CIND] = min(actlambda);
			else
				% Bland's rule for anti-cycling: if there is more than one 
				% negative Lagrangian multiplier then delete the constraint
				% with the smallest index in the active set.
				CIND = find(ACTIND == min(ACTIND(indlam)));
			end

			[Q,R]=qrdelete(Q,R,CIND);
			Z = Q(:,nvars);
			oldind = ACTIND(CIND);
		else
			lambda(ACTIND)= normf * (rlambda./normA(ACTIND));
			return
		end
	end %if ACTCNT<nvars
	if (is_qp)
		Zgf = Z'*gf; 
		if (norm(Zgf) < 1e-15)
			SD = zeros(nvars,1); 
		elseif ~length(Zgf) 
			% Only happens in -ve semi-definite problems
			disp('Warning: QP problem is -ve semi-definite.')
			SD = zeros(nvars,1);
		else
% !DR1 - if the condition remains equal (ly bad), we know
%        something is wrong.
if ((rcond (Z'*H*Z) == prev_rcond) & (prev_rcond < 1.0e-10))
	bla = rcond (Z'*H*Z)
	prev_rcond
	disp ('Matrix condition does not change')
	X = [];
	return
else
	prev_rcond = rcond(Z'*H*Z);
end
			SD=-Z*((Z'*H*Z)\(Zgf));
		end
		% Check for -ve definite problems
		% if SD'*gf>0, is_qp = 0; SD=-SD; end
	else
		if ~simplex_iter
			SD = -Z*Z'*gf;
			gradsd = norm(SD);
		else
			gradsd = Z'*gf;
			if  gradsd > 0
				SD = -Z;
			else
				SD = Z;
			end
		end
		if abs(gradsd) < 1e-10  % Search direction null
			% Check whether any constraints can be deleted from active set.
			% rlambda = -ACTSET'\gf;
			if ~oldind
				rlambda = -R\(Q'*gf);
			end
			actlambda = rlambda;
			actlambda(1:neqcstr) = abs(actlambda(1:neqcstr));
			indlam = find(actlambda < errnorm);
			lambda(ACTIND) = normf * (rlambda./normA(ACTIND));
			if ~length(indlam)
				return
			end
			cindmax = length(indlam);
			cindcnt = 0;
			newactcnt = 0;
			while (abs(gradsd) < 1e-10) & (cindcnt < cindmax)
				
				cindcnt = cindcnt + 1;
				if oldind
					% Put back constraint which we deleted
					[Q,R] = qrinsert(Q,R,CIND,A(oldind,:)');
				else
					simplex_iter = 0;
					if ~newactcnt
						newactcnt = ACTCNT - 1;
					end
				end
				CIND = indlam(cindcnt);
				oldind = ACTIND(CIND);

				[Q,R]=qrdelete(Q,R,CIND);
				[m,n]=size(ACTSET);
				Z = Q(:,m:n);

				if m ~= nvars
					SD = -Z*Z'*gf;
					gradsd = norm(SD);
				else
					gradsd = Z'*gf;
					if  gradsd > 0
						SD = -Z;
					else
						SD = Z;
					end
				end
			end
			if abs(gradsd) < 1e-10  % Search direction still null
				return;
			end
			lambda = zeros(ncstr,1);
			if newactcnt 
				ACTCNT = newactcnt;
			end
		end
	end

	if simplex_iter & oldind
		ACTIND(CIND)=[];
		ACTSET(CIND,:)=[];
		CIND = nvars;
	end 

% !DR1 - If we have cycled through more than 100 iterations, we know
%        something is wrong.
	iteration = iteration + 1;
  if (verbosity > 0)
    fprintf ('*');
  end
	if (iteration > maxiterations)
		disp ('More than enough iterations')
		X = []
		return;
	end;

end % while 1
