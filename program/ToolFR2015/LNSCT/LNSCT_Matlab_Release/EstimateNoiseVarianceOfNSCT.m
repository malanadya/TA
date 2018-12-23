function nvar_Monto_Carlo = EstimateNoiseVarianceOfNSCT(Height, Width, pfilt, dfilt, levels)
% Estimate the noise variance in the NSCT domain
%
%--------------------------------------------------------------------------
% Reference: For an additive Gaussian white noise of zero
% mean and nsts standard deviation, the noise standard deviation in the
% NSCT domain (in vector form) is 
% nstdNSCT=nstd * nstd_Monto_Carlo
%%
% Number of interations
niter = 50;
J=size(levels,2);
%-------------method 1--------------------
% for t=1:niter
%     noisePic=255*nstd.*randn(Height, Width);
%     coeffs= nsctdec(noisePic, levels, dfilt, pfilt );    
% 
%     for j=1:J
%       for k=1:2^levels(J-j+1)
%            subband=coeffs{J+2-j}{k};
%            if t==1
%                nvarNSCT{J+2-j}{k}=0;
%            end
%            nvarNSCT{J+2-j}{k}=nvarNSCT{J+2-j}{k}+(subband.^2)/niter;
%       end
%     end
%     
% end
%--------------------------------method 2----------------------
for t=1:niter
    noisePic=randn(Height, Width);  
    coeffs= nsctdec(noisePic, levels, dfilt, pfilt );    

    for j=1:J
      for k=1:2^levels(J-j+1)
           subband=coeffs{J+2-j}{k};
           if t==1
               nstd_Monto_Carlo{J+2-j}{k}=subband.^2;
           end
           nstd_Monto_Carlo{J+2-j}{k}=nstd_Monto_Carlo{J+2-j}{k}+subband.^2;
      end
    end
end

 for j=1:J
      for k=1:2^levels(J-j+1)
        nvar_Monto_Carlo{J+2-j}{k}=nstd_Monto_Carlo{J+2-j}{k} ./ (niter - 1);
      end
 end


