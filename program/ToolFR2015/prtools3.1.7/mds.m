% MDS Non-linear mapping by multi-dimensional scaling (Sammon)
%
%  [W,E] = MDS (D,k,Q,INIT,INSPECT)
%
%  Calculates a non-linear mapping W of a distance matrix D to k dimensions.
%  A stress measure with parameter Q (-2 <= Q <= 2) is used. 
%  INIT influences the initialisation method: 'pca' or 'random'. Finally, when 
%  INSPECT > 0 (and 1 <= k <= 3), progress is plotted during the minimisation 
%	 process after every INSPECT iterations.
%
%  Returns an approximate mapping W and the final stress E.
%  New objects may be mapped by E*W in which E is a n x m distance matrix
%  to the original set of m objects.
%
%  Defaults: k = 2, Q = 0, INIT = 'pca', INSPECT = 0.
%
% See also: mappings, datasets, classs

% Copyright: E. Pekalska, R.P.W. Duin, ela@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,err] = mds (D,d,q,init,inspect)

	if (nargin < 5), inspect = 0; 											end;
	if (nargin < 4), init = 'pca'; 											end;
	if (nargin < 3), q = 0; 														end;
	if (nargin < 2), d = 2; 														end;
	if nargin < 1 | isempty(D)
		W = mapping('mds',{d,q,init,inspect});
		return
	end
	if isa(d,'mapping')
		W = mds_ela(D,d);
		return
	end

	ela_stress = { 'stress3', 'stress1', 'stress2', 'stress4', 'stress5' };

	if ((q < -2) | (q > 2)), error ('q out of range [-2,-1,0,1,2]'); 	end;
	if (d < 1)
 		 error ('d out of range');
 	end;

	if (inspect > 0), 
		ela_inspect = 1; update = inspect; 
	else
		ela_inspect = -1; update = -1;
	end;

	switch (init)
		case 'pca', 		ela_init = 'kl';
		case 'random', 	ela_init = 'randv';
		otherwise, 			error ('unknown initialisation method');
	end;

	[W,J,err] = mds_ela (D,d,ela_stress{q+3},'scg',ela_init,ela_inspect,update);

	err = err(end);

return


%MDS - Multidimensional Scaling; a variant of Sammon mapping
%
%   [W,J,err] = mds(D, Y, stress, optim, init, status)
%                  or
%   [W,J,err] = mds(D, n, stress, optim, init, status)
%
%  Finds a nonlinear MDS map of objects represented by a distance matrix D,
%  given either n, the dimensionality, or Y, the initial configuration.
%  The parameter stress is a string of the function name standing for the 
%  Sammon stress criterion. The following criteria are possible: 
%  'stress1', ...,'stress5','sqstress1' or 'sqstress2'. 
%  The parameter: optim is a string standing for a minimization method used 
%  for the stress optimization:
%    'pn'   - Pseudo-Newton
%    'scg'  - Scaled Conjugate Gradients
%    'h'    - hybrid
%  
%  If for any different points i and j the distance D(i,j) = 0, then one of
%  them is superfluous. The index of such points is returned in J.
%
%  DEFAULT:
%    n      = 2 
%    stress = 'stress1' 
%    optim  = 'pn' 
%    init   = 'cs' 
%    status = 1 
%

function [W,J,err] = mds_ela (d,y,stress,optim,init,st,update)

if nargin < 6, st = 1; end
if nargin < 5, init = 'cs'; end
if nargin < 4, optim = 'pn'; end
if nargin < 3, stress = 'stress1'; end
if nargin < 2 | isempty(y), y = 2; end
if nargin < 1 | isempty(d)
  W = mapping('mds',{y,stress,optim,init,st}); return
end


if (isa(d,'dataset') | isa(d,'double')) 
  if isa(y,'mapping')
    [w,classlist,map,k,c,vscale,pars] = mapping(y);
    W = d * w;
    return; 
  end
end


[lab,lablist,m,mm,c,prob,featl] = dataset(d);
[m2,n] = size(y);

if m ~= mm,
  error('Distance matrix should be a square matrix.')
end

%DR
plotlab = getlab(d);

d = +d;
                          
[I,J,P] = reppoints(d);
d(J,:)  = [];              
d(:,J)  = [];

%DR
plotlab(J) = [];    

if max(m2,n) == 1,
  n = y;
  y = mds_init(d,n,init);
else
  if m ~= m2, 
    error('Number of rows of the distance matrix D and the starting configuration Y should be the same.');
  end;
  y = +y;
  y(J,:) = [];
end
y = y + 0.01 * mean(max(y)-min(y)) * rand(size(y));    % add a bit noise to avoid stacking in a local minimum


printinfo (stress,optim,st);
fname = ['sammap_',optim];
%DR [yy,err] = feval(fname,d,y,stress,st);
[yy,err] = feval(fname,d,y,stress,st,plotlab,update);
yy = yy - ones(length(yy),1)*mean(yy);

if rank(d) < m,
  WW = pinv(d)*yy;
else
  WW = d \ yy;
end


W = zeros (m,n);
W(I,:) = WW;                     

W = mapping('mds',W,[],m,n,1);
return







function printinfo (stress,optim,st)
if (~isempty(st) & (st >= 0))
  fprintf (st,'Sammon mapping, error function: %s\n',stress);
  switch optim
    case 'pn',  
      fprintf(st,'Minimization by Pseudo-Newton algorithm\n');
    case 'scg',  
   	 fprintf(st,'Minimization by Scaled Conjugate Gradients algorithm\n');
    case 'h',  
      fprintf (st,'Minimization by a hybrid algorithm\n');
    otherwise 
      error(strcat('Posible initialization methods: pn (Pseudo-Newton), ',...
                   'scg (ScaledConjugate Gradients) or h (hybrid).'));
end;
end;

function [I,J,P] = reppoints(d)

[m,mm] = size(d);
if m ~= mm,
  error('Distance matrix should be a square matrix.')
end

I = 1:m;
J = []; 
P = [];
K = intersect (find (triu(ones(m),1)), find(d < 1e-20));
if ~isempty(K),
  P = mod(K,m);
  J = fix(K./ m) + 1;            % J - index of repeated points to be removed   
  I(J) = [];                     % I - index of points left 
end


%MDS_INIT Initialization for MDS (variants of Sammon) mapping
% 
%         Y = mds_init (D,n,initm)
%
%  Y is a configuration of points in an n-dimensional space, used as a starting
%  point for an MDS mapping based on the distance matrix D. 
%
%  The parameter initm is a string standing for the initilization method:
%    'randp'   - linear mapping of D on n randomly (uniform distribution) chosen vectors
%    'randv'   - randomly (uniform distribution) chosen vectors
%    'maxv'    - n columns of D with the largest variances
%    'kl'      - Karhunen Loeve projection (linear mapping) of D (first n eigenvectors)
%    'cs'      - Classical Scaling
% 
%  DEFAULT:
%    n     = 2
%    initm = 'randp'  
%


function [y,init] = mds_init(d,n,initm)

if nargin < 2, n = 2; end
if nargin < 3, initm = 'randp'; end

[m,mm] = size(d);

if m ~= mm,
  error('Distance matrix should be a square matrix.')
end

lab = getlab(d);
d   = +d;


[I,J,P] = reppoints(d);
d(J,:)  = [];              
d(:,J)  = [];
m       = m - length(J);

switch initm		
  case 'randp',
    yy = d * rand(m,n);

  case 'randv',
    yy = rand(m,n);

  case 'maxv',
    U     = std(d);
    [V,I] = sort(-U);
    yy    = d(:,I(1:n));    

  case 'kl',
% DR  [E,L] = eigs(cov(+d),n);
eigs_opts.disp = 0;
    [E,L] = eigs(cov(+d),n,'LM',eigs_opts);
    yy    = d * E;   

  case 'cs',
    yy = mds_cs(d,n);   

  otherwise,   
    error ('The possible initialization methods are: randp, randv, maxv or kl.');  
end


y = zeros (m,n);
y(I,:) = yy;                      % I - index of points left 

for k=length(J):-1:1
  y(J(k),:) = y(P(k),:);          % J - index of points removed 
end 
y = dataset(y,lab);


%SAMMAP_SCG Sammon iterative nonlinear mapping
%
%    [Y,err] = sammap_scg (D, Y, stress, status)
%
%  Map of objects given by a distance matrix D into an n-dimensional object 
%  Y by iteratively minimizing the original Sammon stress. Ys is the starting
%  configuration (see mds_init) for the Sammon mapping. The minimization is 
%  done by the Scaled Conjugate Gradients algorithm.
%  Status = 0/1 and 1 stands for printing the stress after each iteration.
%
%

function [y,err] = sammap_scg (ds, y, stress, st, lab, update)

if nargin < 3, stress = 'stress1'; end;
if nargin < 4, st = 1; end;

[m,n] = size(y);

y = y + 0.001*mean(max(y)-min(y))*randn(m,n);
d = sqrt(distm(y));
d (1:m+1:end) = 1;     
ds(1:m+1:end) = 1;     

it   = 0;
eold = inf;                                     % previous error
e    = feval(stress, y, ds);
err  = e;
if (~isempty(st) & (st > 0)),
	fprintf(st,'iteration: %4i   stress: %3.8d\n',it,e); 
end;

sigma0  = 1e-8;                                  
lambda  = 1e-8;                                 % regularization parameter                
lambda1 = 0;
etol    = sqrt(eps);                            % approx. of the machine precision value

[e,g1]  = feval(stress, y, ds, d);              % g1 - gradient 
p       = -g1;                                  % direction of decrease 
ggnew   = g1(:)' * g1(:);
success = 1;



if ggnew < 1e-15,
  fprintf('Gradient is nearly zero: %3.8d\n', ggnew);
  fprintf('Initial configuration is the right one.\n');  
  break;
end


while (abs(eold - e) > etol * (1 + e) | it < 10),   
  g0   = g1;                                  % previous gradient 
  pp   = p(:)' * p(:);
  eold = e;

%DR
	if ((st > 0) & (mod(it,update)==0)), mds_plot(y,lab,e); end;

  if success,
    sigma  = sigma0/sqrt(pp);                 % sigma - small step from y to yy
    yy     = y + sigma .*p;
    [e,g2] = feval (stress, yy, ds); 
    s      = (g2 - g1)/sigma;                 % approximation of  H*p,  where H - the hesjan  
    delta  = p(:)' * s(:);
  end

  delta = delta + (lambda1 - lambda) * pp;
  if delta < 0,                               % indicate that the Hesiaan is negative definite
    lambda1 = 2 * (lambda - delta/pp);
    delta   = -delta + lambda * pp;
    lambda  = lambda1; 
  end

  mi = - p(:)' * g1(:);
  yy = y + (mi/delta) .*p;
  ee = feval (stress, yy, ds); 
  Dc = 2 * delta/mi^2 * (e - ee);          % measure of how well the approximation of e(y+alpha.*p) is

  e = ee;
  if Dc >= 0,
    y = yy;
    [ee, g1] = feval (stress, yy, ds); 
    ggnew    = g1(:)' * g1(:);
    lambda1  = 0;
    success  = 1;

    beta = max (0, (g1(:)' * (g1(:) - g0(:)))/mi);
    p    = -g1 + beta .* p;

    if (g1(:)'*p(:) >= 0 | mod(it-1,n*m) == 0),
      p = -g1;
    end   

    if Dc >= 0.75,
      lambda = 0.25 * lambda;
    end

    it  = it + 1; 
    err = [err; e];
		if (~isempty(st) & (st > 0)),
	    fprintf (st,'iteration: %4i   stress: %3.8d\n',it,e); 
		end;

  else  
    lambda1 = lambda;
    success = 0;  
  end

  if Dc < 0.25,
    lambda = lambda + delta * (1 - Dc)/pp;
  end
end
return


%STRESS2 - Sammon stress no.2
%
%     [e,G1,G2] = stress2 (Y,Ds,D)
%
% The Sammon stress between the original distance matrix Ds
% and the distance matrix D of the mapped configuration Y, expressed 
% as follows:
%
%   e = 1/(sum_{i<j} Ds_{ij}^2)  sum_{i<j} (Ds_{ij} - D_{ij})^2
%
% G1 is the gradient direction, G2 is the approximation of the hessian
% of the stress function, used in the routine mds.
% 
% D is an optional parameter.
%



function [e,g1,g2,cc] = stress2 (y,ds,d)

if nargin < 3,
  d = sqrt(distm(y));     
end

[m,n] = size(y);
m2 = m^2;

d  = +d;
ds = +ds;

if any([size(d), size(ds)] ~= m), 
  error ('The sizes of matrices do not match.');
end

if ~ds(1,1),
  ds(1:m+1:end) = 1;     
end                               

if ~d(1,1),
  d(1:m+1:end) = 1;
end                               


I = 1:m2; J = [];
K = intersect (find (triu(ones(m),1)), find(ds < 1e-20));
if ~isempty(K),
  J = fix(K./ m) + 1;                % J - index of repeated points to be removed   
  P = [];
  for k=1:length(J),
    j = J(k);
	 P = [P (j-1)*m+1:j*m  j:m:m2];
  end    
  I(P) = [];
end


c  = sum(ds(I).^2)-m+length(J);
cc = -2/c; 
e  = sum(sum((ds(I)-d(I)).^2))/c;


if nargout > 1,
  I    = (1:m2)';
  K    = find (d <= eps);
  I(K) = [];

  h1    = zeros(m2,1);
  h1(I) = (ds(I) - d(I)) ./ (d(I));
  h1    = reshape (h1',m,m);
  g2    = h1 * ones(m,n);
  g1    = cc * (g2.*y - h1*y);          % gradient

  if nargout > 2,
    h2    = zeros(m2,1);
    h2(I) = - ds(I)./(d(I).^3);
    h2    = reshape (h2',m,m);
    g2    = cc * (g2 + (h2 * ones(m,n)).*y.^2 + h2*y.^2 - 2*(h2*y).*y);
  end
end


function mds_plot (y, lab, e)

	y = +y;

	if (size(y,2) <= 3)
    cla; hold on;

		if (ischar (lab))
	    scatterd (dataset(y,lab),min(size(y,2),3),'both');
		else
			scatterd (dataset(y,lab),min(size(y,2),3));
		end;

    title (sprintf ('STRESS: %f', e));
    axis equal; drawnow;

  end;

return
