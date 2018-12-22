% compute_approx_model: Compute approximate classifier from LIBSVM model
%
% model = compute_approx_model(svmmodel,param)
%
% svmmodel - model output form LIBSVM  
% param.NUMSAMPLES - number of uniform samples in the approximation.
% param.BINARY - fast computation using binary search (valid for IKSVM only)
%
%
% Based on the algorithm from : 
%
% Classification using Intersection Kernel SVMs is efficient, 
% Subhransu Maji, Alexander C. Berg, Jitendra Malik, CVPR 2008
%
% Author : Subhransu Maji         Date: Feb 1, 2010
    
function model = compute_approx_model(svmmodel,param)
    if(nargin < 2)
        param.NSAMPLE = 100;
        param.BINARY  = 1;
        param.MEX     = 1;
        fprintf('Warning : using default parameters..\n');
    end
    if(length(svmmodel.Label) ~= 2)
        model = [];
        distp('[Error] Only binary classifier supported.');
        return;
    end
    KERNEL_TYPE = svmmodel.Parameters(2);
    if(KERNEL_TYPE ~= 5 && KERNEL_TYPE ~= 6 &&  KERNEL_TYPE ~= 7)
        model = [];
        disp('[Error] Unsupported Kernel type (only -t 5,6,7) are supported.');
        return;
    end
    
    % copy the parameters from svmmodel
    model.Parameters = svmmodel.Parameters;
    model.nr_class   = svmmodel.nr_class;
    model.totalSV    = svmmodel.totalSV;
    model.rho        = svmmodel.rho;
    model.Label      = svmmodel.Label;
    model.ProbA      = svmmodel.ProbA;
    model.ProbB      = svmmodel.ProbB;
    model.nSV        = svmmodel.nSV;
    
    %sample the 1-dimensional functions uniformly 
    featdim  = size(svmmodel.SVs,2);
    model.fa = zeros(param.NSAMPLE, featdim);
    model.fx = zeros(param.NSAMPLE, featdim);
    
    global alpha;
    alpha = svmmodel.sv_coef; 
    
    global sumalpha;
    sumalpha = sum(alpha);
    
    for i = 1:featdim
        [model.fx(:,i),model.fa(:,i),model.a(i),model.b(i)] = ...
                    sample_function(KERNEL_TYPE, svmmodel.SVs(:,i),param);
    end
end

%sample the one dimensional function uniformly from min(x) to max(x)
function [y,f,a,b] = sample_function(KERNEL_TYPE, x, param)
    global alpha;
    
    y = linspace(min(x),max(x),param.NSAMPLE); y = y';
    
    %index interpolating coefs
    stepsize = (y(2)-y(1));
    a = 1/stepsize;
    b = -y(1)/stepsize;
    
    if (KERNEL_TYPE == 5 && param.BINARY)
        f = mex_sample_weighted_int_kernel(alpha,x,y);
    else
        f = mex_sample_weighted_kernel(alpha,x,y,KERNEL_TYPE);
    end
end





