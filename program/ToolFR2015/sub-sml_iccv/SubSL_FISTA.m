function  result = SubSL_FISTA(Xtr, SS, DS, beta, di, options)
% M and G are not restricted to be P.S.D.
%Distance metric and similarity learning using FISTA (fast proximapping) method
%\min_{M>=0} \sum_{i,j} (1+y_ij( (x_i-x_j)M(x_i--x_j) - x_i*G*x_j ) )_+  +
%lamda*|M-M0|^2+  \gamma \|G-G_0\|^2
%using the analysis of yiming's NIPS paper in 2007
%Qiong, 09/08/2012
%%INPUTS:
% Xtr: input data ib the form of sample x  feature
% SS:  similarity pair indices
% DS:  dissimilarity  pair indices
% beta: regularization parameter
% di: the dimension of the intrapersonal subspace
% options:  maximum iteration number, stopping torelance in MATLAB structure form
%%OUTPUTS:
%result:  MATLAB strucuture form which inlcudes  distance matrix, running
%time, evolution of objective value

if nargin < 3 || nargin > 6
    help SubSL_FISTA
end
if nargin < 5
    di = 100;
end
if nargin < 4
    beta = 1e-1;
end

if isfield(options,'tol')  %choose stopping shreshold
    tol = options.tol;
else
    tol = 1e-6;
end
if isfield(options,'maxiter')  %choose stopping shreshold
    maxiter = options.maxiter;
else
    maxiter = 5e3;
end
if isfield(options,'display')
    display = options.display;
else
    display = 1;
end
%=========================================================================
nos_sim = size(SS,1) ;  %number of similarity pairs
nos_dsim = size(DS,1);  %number of dissimilarity pairs
[ns, nf] = size(Xtr);
ut = ones(nos_sim,1); 
XS = SODW(Xtr', SS(:,1), SS(:,2), ut);
XS = (XS + XS')./2 + 1e-6.*eye(nf);  
LS = chol(XS,'lower');
Xtr = linsolve(LS,Xtr');
Xtr = Normalisation(Xtr');

% % choose the dimension of intra-personal subspace
% [V, D] = eigs(XS, di);
% LS = diag(diag(D).^(-1/2))*V';
% Xtr = LS*Xtr';
% Xtr = Xtr';
% Xtr = Normalisation(Xtr);

%%initializing
Id = eye(nf); ut1 = ones((nos_sim+ nos_dsim), 1);%eye(nf)
alphap = ut1./(nos_sim+ nos_dsim); alpha = alphap; alphapp = alpha-alphap;
tp = 0;t = 1;L=1;%t=(1+sqrt(5))/2;
%setting parameters
Count = 1;    % main loop flag
iter = 1;     %iteration number
Fval = []; Fvaly = [];     %objective value
change_Fval = [];   %relative change of objective value
t0 = cputime;
%%------------------------Main Loop-----------------------------------
while (iter < maxiter) && Count
    
       betat = (tp-1)/t;
       xp = alpha+betat.*(alphapp);
    
%   compute f(xp)'(=gradfxp)  
        
        
        SStemp_G = SODW_SIM(Xtr', SS(:,1), SS(:,2), xp(1:nos_sim));
        DStemp_G = SODW_SIM(Xtr', DS(:,1), DS(:,2), xp(1+nos_sim:end)); 
        gradfyp_G = SStemp_G- DStemp_G;        
       
        G_xp = Id + (1/beta).*gradfyp_G;
        G_xp = (G_xp + G_xp')./2;
        
        M_xp = zeros(nf);
        H1_POS = -Score_SML(Xtr, SS(:,1), SS(:,2), M_xp, G_xp); % minus of similarity scores(x'Gy) for the negative pairs
        H1_NEG = Score_SML(Xtr, DS(:,1), DS(:,2), M_xp, G_xp); % similarity scores for the negative pairs
        a1 = 1+ [H1_POS; H1_NEG];
       
        gradfxp = -a1;
        alphap = alpha;
        
        f_xp = sum(xp.*a1)+ (1/(2*beta))*trace((gradfyp_G)^2);
        f_xp = -f_xp;
     
    while (1)
     % compute fnew(f(alpha)), f(xp) and ftaylor  
        alpha = xp - (1/L).*gradfxp;
        alpha = min(max(alpha,0),1);
       
        
        SStemp_G = SODW_SIM(Xtr', SS(:,1), SS(:,2), alpha(1:nos_sim));
        DStemp_G = SODW_SIM(Xtr', DS(:,1), DS(:,2), alpha(1+nos_sim:end)); 
        gradfap_G = SStemp_G - DStemp_G;
        
        
        G_alpha = Id + (1/beta).*gradfap_G;
        G_alpha = (G_alpha + G_alpha')./2;
%         [V,D]=eig(M_alpha);
%         D(find(D<0))=0;
%         M_alpha=V*D*V';
        
        M_alpha = zeros(nf);
        H2_POS = -Score_SML(Xtr, SS(:,1), SS(:,2), M_alpha, G_alpha); % minus of similarity scores for the negative pairs
        H2_NEG = Score_SML(Xtr, DS(:,1), DS(:,2), M_alpha, G_alpha); % similarity scores for the negative pairs
        a2 = 1+ [H2_POS; H2_NEG];
        
        Fnew = sum(alpha.*a2)+ (1/(2*beta))*trace((gradfap_G)^2);
        Fnew = -Fnew;
       
        alpha2 = alpha-xp;
        Ftaylor = f_xp + sum(gradfxp.*alpha2) + (L/2)*(sum(alpha2.^2));      

        
        if Fnew <= Ftaylor
            Fval = [Fval,Fnew];
            Fvaly = [Fvaly,f_xp];
            break;
        else
            L = 2*L;
        end
    end    
    tp = t;
    t = (1+sqrt(1+4*t^2))/2;
    alphapp = alpha-alphap;
    
    % checking the change of the objective value
    if display == 1
        if iter > 2
            change_Fval = [change_Fval,   abs(Fval(end) - Fval(end-1))/abs(Fval(end)+eps)];
            
            if ~mod(iter,5)
                fprintf('| Iters:  %d | Objective value: %5.3e   |  relative change %5.3e |\n', iter, Fval(end), change_Fval(end));
            end
            
            if change_Fval(end)<tol
                Count = 0;
            end
        end
    end
    iter = iter+1;
end

%output
result.time = cputime-t0;
result.MM = M_alpha;
result.GG = G_alpha;
result.LS = LS;   %transfromation matrix
result.alpha = alpha;
result.fvalue = Fval;
result.change_fvalue = change_Fval;




