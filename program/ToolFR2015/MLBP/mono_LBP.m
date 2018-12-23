function [tHist] = mono_LBP(im)

% ========================================================================
% Copyright(c) 2010 Lin ZHANG, Lei Zhang, Zhenhua Guo, and David Zhang 
% All Rights Reserved.
% ----------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is hereby
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%----------------------------------------------------------------------
% This is an implementation of the algorithm for calculating the
% monogenic-LBP histogram of the given image. The code to generate the LBP
% is required in this implementation. You can get the LBP code from
% http://www.ee.oulu.fi/mvg/page/lbp_matlab. 
%----------------------------------------------------------------------
% Please refer to the following paper and the website
%
% Lin Zhang, Lei Zhang, Zhenhua Guo, and David Zhang, "Monogenic-LBP: a new 
% approach for rotation invariant texture classification", in: Proc. IEEE
% International Conference on Image Processing, 2010, Hong Kong.
%
% http://www.comp.polyu.edu.hk/~cslinzhang
% http://www.comp.polyu.edu.hk/~cslzhang
%----------------------------------------------------------------------
%
%Input : im: the gray-scale image whose monogenic-LBP histogram you want
%Output: tHist: the monogenic-LBP histogram of the given image. It is a
%vector with 540 bins.
%========================================================================

%parameters used in LBP
radiusForLBP = [1 3 5];
samplesRateForLBP = [8 16 24];

%======================================
% mapping is used in calculating LBP features. It can be pre-computed as
% follows.
%
% mappingArray = {};
% for scaleIndex = 1:3
%     mappingArray{scaleIndex} = getmapping(samplesRateForLBP(scaleIndex),'riu2');
% end
% save('mappingArray.mat', 'mappingArray');
%========================================

%Here, I assume that the mapping is pre-computed and stored as
%'mappingArray.mat'
mappingArray = load('mappingArray.mat');
mappingArray = mappingArray.mappingArray;

%wavLengths are used in constructing the band-pass filter.
wavLengths = [3.6 7.2 14.4];
%In fact, the Riesz kernels can also be pre-computed.
[Rx, Ry, Rxx, Rxy, Ryy, LOP] = generateRieszKernel(200, 200, wavLengths);

%the image need some preprocessing
im = double(im);
Ex = mean2(im);
sigma = std(im(:));
im = (im - Ex) ./ sigma;

tHist = [];

for scaleIndex = 1:3
    fftIm = fft2(double(im));
    bpIm = real(ifft2(fftIm .* LOP(:,:,scaleIndex))); 
    
    RxRes = real(ifft2(fftIm .* Rx(:,:,scaleIndex)));
    RyRes = real(ifft2(fftIm .* Ry(:,:,scaleIndex)));
 	RxxRes = real(ifft2(fftIm .* Rxx(:,:,scaleIndex)));
    RxyRes = real(ifft2(fftIm .* Rxy(:,:,scaleIndex)));
    RyyRes = real(ifft2(fftIm .* Ryy(:,:,scaleIndex)));
    
    bpIm = bpIm(21:180, 21:180);%sarebbe H di MBP
    RxRes = RxRes(21:180, 21:180);%sarebbe Hx di MBP
    RyRes = RyRes(21:180, 21:180);%sarebbe Hy di MBP
    RxxRes = RxxRes(21:180, 21:180);
    RxyRes = RxyRes(21:180, 21:180);
    RyyRes = RyyRes(21:180, 21:180);
    
    phaseAng = atan2(sqrt(RxRes .^ 2 + RyRes .^ 2), bpIm);
    detT = RxxRes .* RyyRes - RxyRes .^ 2;

    phaseLevel = 5;
    phaseCode = ceil(phaseAng / (pi / phaseLevel));
    phaseCode = phaseCode + (phaseCode == 0);
    
    surfaceCode = (detT > 0) + 1;
    
    codePlane = [];
    
    %to make the LBPCode matrix the same size as phaseCode(or surfaceCode)
    if scaleIndex == 1
        imForLBP = im(20:181, 20:181);
    elseif scaleIndex == 2
        imForLBP = im(18:183, 18:183);
    else
        imForLBP = im(16:185, 16:185);
    end
    
    mapping = mappingArray{scaleIndex};
    LBPCode = LBP(imForLBP, radiusForLBP(scaleIndex), samplesRateForLBP(scaleIndex), mapping,'other') + 1;

    codePlane(:,:,1) = phaseCode;
    codePlane(:,:,2) = surfaceCode;
    codePlane(:,:,3) = LBPCode;
    code = (codePlane(:,:,3) - 1) * phaseLevel * 2 + (codePlane(:,:,2) - 1) * phaseLevel + codePlane(:,:,1);

    if scaleIndex == 1
        histAtThisScale = zeros(phaseLevel * 2 * 10,1);
    elseif scaleIndex == 2
        histAtThisScale = zeros(phaseLevel * 2 * 18,1);
    else
        histAtThisScale = zeros(phaseLevel * 2 * 26,1);
    end
    
    [rows, cols] = size(code);
    for rowIndex = 1:rows
        for colIndex = 1:cols
            codeValue = code(rowIndex, colIndex);
            histAtThisScale(codeValue) = histAtThisScale(codeValue) + 1;
        end
    end

    histAtThisScale = histAtThisScale / sum(histAtThisScale);
    tHist = [tHist; histAtThisScale];
end
return;

%==========================================================================
%This function returns the Riesz transforms kernels and the band-pass
%filter kernel (LOP)
function [Rx, Ry, Rxx, Rxy, Ryy, LOP] = generateRieszKernel(rows, cols, wavLengths)

    [u1, u2] = meshgrid(([1:cols]-(fix(cols/2)+1))/(cols-mod(cols,2)), ...
			([1:rows]-(fix(rows/2)+1))/(rows-mod(rows,2)));

    u1 = ifftshift(u1);  
    u2 = ifftshift(u2);
    
    radius = sqrt(u1.^2 + u2.^2);    
    radius(1,1) = 1;
    
    R1 = -i*u1./radius;  
    R2 = -i*u2./radius;
    radius(1,1) = 0;
    
    for wavIndex = 1:length(wavLengths)
        LOP(:,:,wavIndex) = -4 * pi^2 * (radius .^2) .* exp(-2*pi * radius * wavLengths(wavIndex));
        Rx(:,:,wavIndex) = R1 .* LOP(:,:,wavIndex); 
        Ry(:,:,wavIndex) = R2 .* LOP(:,:,wavIndex); 
        Rxx(:,:,wavIndex) = Rx(:,:,wavIndex) .* R1;
        Rxy(:,:,wavIndex) = Rx(:,:,wavIndex) .* R2;
        Ryy(:,:,wavIndex) = Ry(:,:,wavIndex) .* R2;
    end
return;