% The function applies the wavele denoising normalization to an image.
% 
% PROTOTYPE
% Y=wavelet_denoising(X,wname,level);
% 
% USAGE EXAMPLE(S)
% 
%     Example 1:
%       X=imread('sample_image.bmp');
%       Y=wavelet_denoising(X);
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%     Example 2:
%       X=imread('sample_image.bmp');
%       Y=wavelet_denoising(X,'haar');
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%     Example 3:
%       X=imread('sample_image.bmp');
%       Y=wavelet_denoising(X,'db1',5);
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%
%
% GENERAL DESCRIPTION
% The function performs photometric normalization of the image X using the
% a wevelet denoising normalization. The function performs kind of soft
% thresholding as it is done in wavelet denoising and obtains the luminance
% estimate. The function takes either one, two or three parameters as
% input.
% 
% The function is intended for use in face recognition experiments and the
% default parameters are set in such a way that a "good" normalization is
% achieved for images of size 128 x 128 pixels. Of course the term "good" is
% relative. The default parameters are set as used in the chapter of the
% AFIA book.
%
%
% 
% REFERENCES
% This function is an implementation of the wavelet denoising photometric 
% normalization technique proposed in:
%
% T. Zhang, B. Fang, Y. Yuan, Y.Y. Tang, Z. Shang, D. Li, and F. Lang,
% “Multiscale Facial Structure Representation for Face Recognition Under 
% Varying Illumination,” Pattern Recognition, vol. 42, no. 2, pp. 252-258, 
% February 2009.
%
%
%
% INPUTS:
% X                     - a grey-scale image of arbitrary size
% wname                 - a string determining the name of the wavelet to
%                         use, "wname" is the same as used in "dtw2", for a
%                         list of options for this variable please refer to
%                         Matlabs internal help on "dwt2", default 
%                         "wname='coif1'"
% level                 - a scalar value determining the number of 
%                         decomposition levels of the wavalet transform,
%                         default "level = 2", good results are also
%                         obtained with "level = 3"
% 
%
% OUTPUTS:
% Y                     - a grey-scale image processed with the wavelet
%                         denoising normalization technique
%                         
%
% NOTES / COMMENTS
% This function applies the wavelet denoising normalization technique to the
% grey-scale image X. 
%
% The function was tested with Matlab ver. 7.5.0.342 (R2007b).
%
% 
% RELATED FUNCTIONS (SEE ALSO)
% histtruncate  - a function provided by Peter Kovesi
% normalize8    - auxilary function
% 
% ABOUT
% Created:        25.8.2009
% Last Update:    25.8.2009
% Revision:       1.0
% 
%
% WHEN PUBLISHING A PAPER AS A RESULT OF RESEARCH CONDUCTED BY USING THIS CODE
% OR ANY PART OF IT, MAKE A REFERENCE TO THE FOLLOWING PUBLICATIONS:
%
% 1. Štruc V., Pavešiæ, N.:Performance Evaluation of Photometric Normalization 
% Techniques for Illumination Invariant Face Recognition, in: Y.J. Zhang (Ed), 
% Advances in Face Image Analysis: Techniques and Technologies, IGI Global, 
% 2010.      
% 
% 2. Štruc, V., Žibert, J. in Pavešiæ, N.: Histogram remapping as a
% preprocessing step for robust face recognition, WSEAS transactions on 
% information science and applications, vol. 6, no. 3, pp. 520-529, 2009.
% (BibTex available from: http://luks.fe.uni-lj.si/sl/osebje/vitomir/pub/WSEAS.bib)
% 
%
% Copyright (c) 2009 Vitomir Štruc
% Faculty of Electrical Engineering,
% University of Ljubljana, Slovenia
% http://luks.fe.uni-lj.si/en/staff/vitomir/index.html
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files, to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.
% 
% August 2009

function Y=wavelet_denoising(X,wname,level);

%% Parameter check
Y=0; %dummy
if nargin == 1
    wname = 'coif1';
    level = 2;
elseif nargin == 2
    level = 2;
elseif nargin >3
    disp('Error! Wrong number of input parameters.')
    return;
end

[a,b]=size(X);
if mod(a,2^level)~=0  ||  mod(b,2^level)~=0
    disp(sprintf('If you want to perform a %i level decomposition the dimensions \n of the image have to be such that "mod(a,2^level)=0" and "mod(b,2^level)=0",\n where a nd b are image dimsneions',level))
    return;
end

if a*b/(4^level)<4
    disp('Please decrease the value of the parameter "level".')
    return;
end

%% Init. operations
X=normalize8((log(normalize8(X)+1)));

%% Process level-wise
tmp = X;
for i=1:level
    [cA1{i},cH1{i},cV1{i},cD1{i}] = dwt2(tmp,wname);
    cH1{i}=thresholding(cH1{i},cD1{i},cA1{i});
    cV1{i}=thresholding(cV1{i},cD1{i},cA1{i});
    cD1{i}=thresholding(cD1{i},cD1{i},cA1{i});
    cA1{i} = cA1{i};
    tmp = cA1{i};
end

%% Invert thresholded 
tmp = cA1{level};
for i=level:-1:1
    %some cheking needed - some of the wavelets seem to sclae wrong
    [row,col]=size(cH1{i});
    tmp = imresize(tmp,[row,col],'bilinear');
    
    %invert
    tmp=idwt2(tmp,cH1{i},cV1{i},cD1{i},wname);
end

%% Construct output and do some post-processing
Y=normalize8(histtruncate(X-tmp,0.2,0.2));




%% Perform nonlinear thresholding procedure
function Y=thresholding(X,HH,Z)

[a,b]=size(X);
Y=zeros(a,b);
HH=X;
T=computeT(X,HH);

for i=1:a
    for j=1:b
        if X(i,j)>=T
            Y(i,j)= X(i,j)-T;
        elseif X(i,j)<=-T
            Y(i,j)= X(i,j)+T;
        else
            Y(i,j)= 0;
        end
    end
end


%% Compute actual threshold
function T=computeT(X,HH,Z);

lambda = 0.1;
sigma = (mad(HH(:))/lambda);
sigma_y = var(X(:));
sigma_x = sqrt(max([sigma_y^2-sigma^2,0]));

if sigma_x==0
    T=max(abs(X(:)));
else
    T=(sigma^2)/sigma_x;
end






