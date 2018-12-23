% The function applies a wavelet-based normalization algorithm to an image.
% 
% PROTOTYPE
% Y=wavelet_normalization(X,fak,wname,mode);
% 
% USAGE EXAMPLE(S)
% 
%     Example 1:
%       X=imread('sample_image.bmp');
%       Y=wavelet_normalization(X);
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%     Example 2:
%       X=imread('sample_image.bmp');
%       Y=wavelet_normalization(X,1.3);
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%     Example 3:
%       X=imread('sample_image.bmp');
%       Y=wavelet_normalization(X,1.2,'sym1');
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%     Example 4:
%       X=imread('sample_image.bmp');
%       Y=wavelet_normalization(X,1.4,'haar','sym');
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
%
%
% GENERAL DESCRIPTION
% The function performs photometric normalization of the image X using the
% a wevelet-based normalization. The function equalizes the histogram of
% the approximation coefficients matrix and emphasizes (by scaling) the
% detailed coefficient in the three directions. As a final step it performs
% an inverse wavelet transform to recover the normalized image.
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
% This function is an implementation of the wavelet-based photometric 
% normalization technique proposed in:
%
% S. Du, and R. Ward, “Wavelet-based Illumination Normalization for Face
% Recognition,” in: Proc. of the IEEE International Conference on Image 
% Processing, ICIP’05, September 2005.
%
%
%
% INPUTS:
% X                     - a grey-scale image of arbitrary size
% fak                   - a scalar value determining the emphasiz of the
%                         detailed coefficients, default "fak=1.5"
% wname                 - a string determining the name of the wavelet to
%                         use, "wname" is the same as used in "dtw2", for a
%                         list of options for this variable please refer to
%                         Matlabs internal help on "dwt2", default 
%                         "wname='db1'"
% mode                  - a string determining the extension mode, for help
%                         on the parameter please type "help dwtmode" into
%                         Matlabs command prompt, default value 
%                         "mode = 'sp0'"
% 
%
% OUTPUTS:
% Y                     - a grey-scale image processed with the wavelet-based
%                         normalization technique
%                         
%
% NOTES / COMMENTS
% This function applies the wavelet-based normalization technique to the
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

function [Y]=wavelet_normalization(X,fak,wname,mode);

%% Parameter Check
Y=0; %dummy
if nargin == 1
    fak = 1.5;
    wname = 'db1';
    mode = 'sp0';
elseif nargin == 2
    wname = 'db1';
    mode = 'sp0';
elseif nargin == 3
    mode = 'sp0';
elseif nargin > 4
    disp('Wrong number of input parameters!')
    return;
end

%% Init operations
X=normalize8(X);

%% Perform the wavlet transform and normalize
[cA,cH,cV,cD] = dwt2(X,wname,'mode',mode);
cA=histeq(uint8(normalize8(cA)));
cH=fak*cH;
cV=fak*cV;
cD=fak*cD;

%% Invert the transform
Y = normalize8(idwt2(cA,cH,cV,cD,wname,'mode',mode));

%% Do some post-processing (or not)
Y=normalize8(histtruncate(Y,2,2));

































