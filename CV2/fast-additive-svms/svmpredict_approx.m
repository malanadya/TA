% svmpredict_approx: Piecewise linear predictions 
%
% d = svmpredict_approx(x,approxmodel,doprob)
%
% x - features 
% approxmodel - approximate model computed from compute_approx_model 
% doprob - do probability estimates (-b 1 for LIBSVM). 
%
%
% Based on the algorithm from : 
%
% Classification using Intersection Kernel SVMs is efficient, 
% Subhransu Maji, Alexander C. Berg, Jitendra Malik, CVPR 2008
%
% Author : Subhransu Maji         Date: Feb 1, 2010

function d = svmpredict_approx(x,approxmodel,doprob)
    if(nargin < 3)
        doprob = 0;
    end
    
    if(doprob && isempty(approxmodel.ProbA))
        fprintf('Error : missing probability model (-b 1 using svmtrain)\n');
        d = []; 
        return;
    end
        
    [m,n]   = size(x);
    
    d       = zeros(m,1) - approxmodel.rho; 
    numbins = size(approxmodel.fx,1)-1;
    
    for i = 1:n
        stepsize = (approxmodel.fx(end,i) - approxmodel.fx(1,i))/numbins;
        if(stepsize < eps) %constant along that dimension
           d = d + approxmodel.fa(1,i); 
        else
           d = d + mex_linear_interpolate(approxmodel.fa(:,i),approxmodel.fx(:,i),x(:,i));
        end
    end
    if(doprob) 
        dp = 1./(1+exp(approxmodel.ProbB + approxmodel.ProbA*d));
        d  = zeros(m,2);
        d(:,1) = dp;
        d(:,2) = 1-dp;
    end
end
