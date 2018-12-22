function [ MFS ] = bw2MFS3D( bw , nEst )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate fractal dimension to form MFS from black & white image.
% input:
%   bw: black and white image
%   nEst: number of estimation level for least square fitting
% 
% output:
%   MFS: one dimension of MFS
%
% Written by Huang Sibin
% Update in 2012.1.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Exception Management
[row,col,frame] = size(bw);
if nEst < 1,error('Number of Estimation is not correct! The number must be nature!');end
if nEst==1
    MFS=log(sum(sum(sum(abs(bw) > 0))))/log(sqrt(row*col*frame));
    return;
end
%% Estimation by box counting approach
for n = 1:nEst    
    if n == 1
        temp_sample = bw;
    else
        temp_map = convn(single(bw),ones(2^(n-1),2^(n-1),2^(n-1)),'valid');
        temp_sample = temp_map(1:2^(n-1):end,1:2^(n-1):end,1:2^(n-1):end);
    end
    N(n) = sum(sum(sum(abs(temp_sample) > 0)));
    R(n) = sqrt(row*col*frame/((8)^(n-1)));
    clear temp_map temp_sample;
end
%% Fitting by Least Square
lsq_x = log(R);
if sum(N ~=0) <2
    MFS = 0;
else 
    lsq_y = log(N(N>0));
    lsq_x = lsq_x(N>0);
    MFS = (mean(lsq_x)*mean(lsq_y) - mean(lsq_x .* lsq_y))/((mean(lsq_x))^2 - mean(lsq_x.^2));
end
%% Exceptional MFS Management
if MFS<0 || isnan(MFS)
    MFS = 0;
end