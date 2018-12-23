function I0=LOG_DCT_1(I,Ddis1,Ddis2)

%% function:
% truncate the low-frequency discrete cosine transform(DCT) coefficients in
% the logarithm DCT domain for face image.
%% input:
% I: 2-D input image
% Ddis1,2: the number of discarded DCT coefficients (Ddis1¡ÁDdis2)
%% output:
% I0: processed image
%% reference:
% W. L. Chen, E. M. Joo and S. Wu. Illumination Compensation and Normalization 
% for Robust Face Recognition using Discrete Cosine Transform in Logarithm domain. 
% IEEE Transactions on Systems, Man and Cybernetics, Part B, 36(2):458¡«466, 2006.
%% About
% author: Xiaohua Xie
% Sun Yat-sen University, China
% email: sysuxiexh@gmail.com
% 2007,08
%%------------------------------- 
if ~exist('I', 'var')
    error('need at least one input!');
end

if ~exist('Ddis1', 'var')
   Ddis1=13;
end

if ~exist('Ddis2', 'var')
   Ddis2=13;
end

I=double(I);
if max(max(I))>200
I(find(I==0))=1;
else
I(find(I==0))=0.01;
end
        
I=log(I);
I=dct2(I);

I(1:Ddis1,1:Ddis2)=0;
I0=idct2(I);