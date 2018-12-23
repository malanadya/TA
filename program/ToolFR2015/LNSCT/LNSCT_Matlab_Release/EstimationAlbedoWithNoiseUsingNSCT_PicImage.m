function v=EstimationAlbedoWithNoiseUsingNSCT_PicImage(Im,levels, lamda,ch,nvar_Monto_Carlo,dfilt, pfilt)
% function: for f=u+v+n, estimate the v from f
% Estimate variance of input image using median operator and then use
% Monte Carlo technique to estimate the noise variance of each subband
% Estimate signal variance locally
% Input:
%   Im:      
%       a matrix, input image with noise
%   lamda:
%        parameter to control the threshold (suggestion: 0.01~0.3)
%   levels:  
%       vector of numbers of directional filter bank decomposition levels 
%       at each pyramidal level (from coarse to fine scale).
%       If the number of level is 0, a critically sampled 2-D wavelet 
%       decomposition step is performed.
%       The support for the wavelet decomposition has not been verified!!!!!!
%   dfilt:  
%       a string, filter name for the directional decomposition step.
%       It is optional with default value 'dmaxflat7'. See dfilters.m for all
%       available filters.
%   pfilt:  
%       a string, filter name for the pyramidal decomposition step.
%       It is optional with default value 'maxflat'. See atrousfilters.m for 
%       all available filters. 
%  ch: a constance, to detect the noise
%
% History: 2008.8.17 by xiexiaohua
%%
%__________________________________
% Check input
if ~isnumeric( levels )
    error('The decomposition levels shall be integers');
end

if isnumeric( levels )
    if round( levels ) ~= levels
        error('The decomposition levels shall be integers');
    end
end

if ~exist('lamda', 'var')
    lamda1 = 0.003;
end;

if ~exist('dfilt', 'var')
    dfilt = 'dmaxflat7' ;
end;

if ~exist('pfilt', 'var')
    pfilt = 'maxflat' ; 
end;
J=size(levels,2);

% Nonsubsampled Contourlet decomposition
coeffs = nsctdec(double(Im), levels, dfilt, pfilt );
temp=coeffs{1};
[Height, Width]=size(temp);
% Veriances
% Require to estimate the noise standard deviation in the NSCT domain first 
% since NSCT is not an orthogonal transform
nvar=EstimateNoiseVariance(coeffs ,3,lamda);
 for j=1:J
      for k=1:2^levels(J-j+1)
       nvarNSCT{J+2-j}{k}=nvar.*nvar_Monto_Carlo{J+2-j}{k};
      end
 end
coeffs{1}=temp*0;

% Caculate the Max coefficients within the same each scale
for j=1:J
    MaxCoeff{J+2-j}=zeros(Height , Width);
    for k=1:2^levels(J-j+1)
        MaxCoeff{J+2-j}=max(MaxCoeff{J+2-j},abs(coeffs{J+2-j}{k}));        
    end
end

% Estimate the v
for j=1:J
    tempMaxCoeff=MaxCoeff{J+2-j};
    for k=1:2^levels(J-j+1)
        subband=coeffs{J+2-j}{k};
        Yvar= EstimateSignalVarianceLocally(subband,5);
        Nvar=nvarNSCT{J+2-j}{k};        
        Xstd=sqrt(max(Yvar-Nvar,0.00001));
        threshold=Nvar./Xstd;
        Nstd=sqrt(Nvar);
        % operated using threshold
        %-------------------------------
        %             T1    , if x>=T1
        % G(x)=   0      , max|x|<c*Nstd, x belongs to subbands of the same scale
        %             -T1  ,  if x<-=T1
        %              x     ,   else
        %------------------------------
        mask1=-threshold;
        mask1(subband>-threshold)=0;
        mask2=threshold;
        mask2(subband<threshold)=0;
        mask3=mask1.*mask2;
        mask3(mask3~=0)=1;
        mask3=ones(size(mask3))-mask3;
        mask3=mask3.*subband;        
        subband=mask1+mask2+mask3;
        subband( tempMaxCoeff<ch*Nstd)=0;
        coeffs{J+2-j}{k}=subband;
    end
end
%Reconstruct image
v = nsctrec( coeffs, dfilt, pfilt) ;