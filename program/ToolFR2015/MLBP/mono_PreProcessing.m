% “Monogenic Binary Pattern (MBP): A Novel Feature Extraction and Representation Model for Face Recognition

function [phaseCode] = mono_PreProcessing(im)

%calcola LBP uniform su magnitude (descrive ogni pixel con 6 bits, usa intorno 3x3, output non è istogramma ma la mappa dei bits che codificano ogni pixel), poi combina binarizzazione della
%componenti orizzontali e verticali della riesz transform
%le 3 immagini decrivono l'immagine originale poi compara con intersezione
%istogrammi

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

%wavLengths are used in constructing the band-pass filter.
wavLengths = [3.6 7.2 14.4];
%In fact, the Riesz kernels can also be pre-computed.
[Rx, Ry, Rxx, Rxy, Ryy, LOP] = generateRieszKernel(size(im,1), size(im,2), wavLengths);

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
    
%     bpIm = bpIm(21:180, 21:180);%sarebbe H di MBP, forse
%     RxRes = RxRes(21:180, 21:180);%sarebbe Hx di MBP, forse
%     RyRes = RyRes(21:180, 21:180);%sarebbe Hy di MBP, forse
    
    Magnitude=(bpIm.^2+RxRes.^2+RyRes.^2)^0.5;
    %estraggo mappa LBP-uniform...cioè risultato1....
    
    BIN(:,:,1)=RxRes>0;
    BIN(:,:,2)=RyRes>0;
    
%     RxxRes = RxxRes(21:180, 21:180);
%     RxyRes = RxyRes(21:180, 21:180);
%     RyyRes = RyyRes(21:180, 21:180);
    
    phaseAng = atan2(sqrt(RxRes .^ 2 + RyRes .^ 2), bpIm);
    detT = RxxRes .* RyyRes - RxyRes .^ 2;

    phaseLevel = 5;
    phaseCode = ceil(phaseAng / (pi / phaseLevel));
    phaseCode = phaseCode + (phaseCode == 0);
    
    surfaceCode = (detT > 0) + 1;
    
    codePlane = [];
    
    
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