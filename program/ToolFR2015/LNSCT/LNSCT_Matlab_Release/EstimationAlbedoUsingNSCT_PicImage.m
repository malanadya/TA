function v=EstimationAlbedoUsingNSCT_PicImage(Im,levels,lamda,nvar_Monto_Carlo,dfilt,pfilt)
% function: for f=u+v, estimate the v from f
% Estimate variance of input image using median operator and then use
% Monte Carlo technique to estimate the noise variance of each subband
% Estimate signal variance locally
% Input:
%   Im:      
%       a matrix, input image
%   lamda:
%       a parameter to control the threshold (suggestion: 0.01~0.3)
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
%
% Output:
%   v:      
%       a matrix, albedo map
%
% History: 2008.8.16 by xiexiaohua
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
    lamda = 0.002;
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
% Veriances
% Require to estimate the noise standard deviation in the NSCT domain first 
% since NSCT is not an orthogonal transform
nvar=EstimateNoiseVariance(coeffs ,3,lamda);
 for j=1:J
      for k=1:2^levels(J-j+1)
       nvarNSCT{J+2-j}{k}=nvar.*nvar_Monto_Carlo{J+2-j}{k};
      end
 end

coeffs{1}=coeffs{1}*0;

for j=1:J
    for k=1:2^levels(J-j+1)
        subband=coeffs{J+2-j}{k};
        Yvar= EstimateSignalVarianceLocally(subband,5);
        Nvar=nvarNSCT{J+2-j}{k};        
        Xstd=sqrt(max(Yvar-Nvar,0.0001));
        threshold=Nvar./Xstd;
        % operated using threshold
        %-------------------------------
        %             T    , if x>=T
        % G(x)=   x      ,  if |x|<T
        %             -T  ,  if x<=-T
        %------------------------------
        subband=sign(subband).*min(abs(subband),threshold);
        coeffs{J+2-j}{k}=subband;
    end
end
%Reconstruct image
v = nsctrec( coeffs, dfilt, pfilt) ;