% The function applies the single scale retinex algorithm to an image.
% 
% PROTOTYPE
% Y = single_scale_retinex(X,hsiz)
% 
% USAGE EXAMPLE(S)
% 
%     Example 1:
%       X=imread('sample_image.bmp');
%       Y=single_scale_retinex(X);
%       figure,imshow(X);
%       figure,imshow(uint8(Y));
% 
%     Example 2:
%       X=imread('sample_image.bmp');
%       Y=single_scale_retinex(X,9);
%       figure,imshow(X);
%       figure,imshow(uint8(Y));
%
%
% GENERAL DESCRIPTION
% The function performs photometric normalization of the image X using the
% SSR technique. It takes either one or two arguments with the first being
% the image to be normalized and second being the size of the Gaussian
% smoothing filter. If no parameter "hsiz" is specified a default value of
% hsiz=15 is used. 
%
% The function is intended for use in face recognition experiments and the
% default parameters are set in such a way that a "good" normalization is
% achieved for images of size 128 x 128 pixels. Of course the term "good" is
% relative.
%
% When studying the original paper of Jabson et al. one should be aware
% that "hsiz" corresponds to the parameter "c".
%
% 
% REFERENCES
% This function is an implementation of the Center/Surround retinex
% algorithm proposed in:
%
% D.J. Jobson, Z. Rahman, and G.A. Woodell, “Properties and Performance of a
% Center/Surround Retinex,” IEEE Transactions on Image Processing, vol. 6, 
% no. 3, pp. 451-462, March 1997.
%
%
%
% INPUTS:
% X                     - a grey-scale image of arbitrary size
% hsiz				    - a size parameter determining the size of the
%                         Gaussian filter (default: hsiz=15), , hsiz is a
%                         scalar value
%
% OUTPUTS:
% Y                     - a grey-scale image processed with the SSR
%                         algorithm
%
% NOTES / COMMENTS
% This function applies the single scale retinex algorithm on the
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
% Created:        19.8.2009
% Last Update:    19.8.2009
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
function Y = single_scale_retinex(X,hsiz)

%% Parameter checking
Y=0;%dummy
if nargin == 1
    hsiz = 15;
elseif nargin > 2
    disp('Wrong number of input parameters!')
    return;
end

%% Init. operations
[a,b]=size(X);
cent = ceil(a/2);
X1=normalize8(X)+0.01; %for the log operation

%% Filter construction
filt = zeros(a,b);
summ=0;
for i=1:a
    for j=1:b
        radius = ((cent-i)^2+(cent-j)^2);
        filt(i,j) = exp(-(radius/(hsiz^2)));
        summ=summ+filt(i,j);
    end
end
filt=filt/summ;

%% Filter image and adjust for log operation 
Z = ceil(imfilter(X1,filt,'replicate','same'));
if(sum(sum(Z==0))~=0)
    for i=1:a
        for j=1:b
            if Z(i,j)==0;
                Z(i,j)=0.01;
            end
        end
    end
end

%% Produce illumination normalized image Y
Y=log(X1)-log(Z);

%% Do some postprocessing - this step is not necessary and can be skipped
[Y, dummy] =histtruncate(Y, 0.2, 0.2);
Y=normalize8(Y);


















