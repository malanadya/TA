% The function applies the non-local means normalization technique to an image
% 
% PROTOTYPE
% Y = nl_means_normalization(X,h,N);
% 
% USAGE EXAMPLE(S)
% 
%     Example 1:
%       X=imread('sample_image.bmp');
%       Y = nl_means_normalization(X);
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%     Example 2:
%       X=imread('sample_image.bmp');
%       Y = nl_means_normalization(X,30);
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%     Example 3:
%       X=imread('sample_image.bmp');
%       Y = nl_means_normalization(X,80,3);
%       figure,imshow(X);
%       figure,imshow(uint8(Y),[]);
% 
%
%
% GENERAL DESCRIPTION
% The function performs photometric normalization of the image X using the
% non-local means algorithm. The algorithm constructs a smoothed image
% based on a weighted sum of similar patches comprising the image. The
% smoothed image is then used to estimate the reflectance which should be
% illumination invariant.
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
% This function is an implementation of the non-local means based 
% photometric normalization proposed in technique described in:
%
% Štruc, V. in Pavešiæ, N.: Illumination Invariant Face Recognition by
% Non-Local Smoothing, Proceedings of BIOID MultiComm, LNCS 5707, Springer, 
% pp. 1-8, September 2009.
% 
% 
% The original non-local means algorithm used in the implemented technique 
% can be found in:
% 
% A. Buades, B. Coll, J.M Morel, "A review of image denoising algorithms, 
% with a new one", Multiscale Modeling and Simulation (SIAM interdisciplinary 
% journal), Vol 4 (2), pp: 490-530, 2005.

%
%
%
% INPUTS:
% X                     - a grey-scale image of arbitrary size
% h                     - a scalar value controling the decay of the
%                         exponential function
% N                     - a scalar value defining the neigborhood size,
%                         i.e., the size of the patches to be used in the
%                         non-local means algorithm, default value "N=2"
% 
% For a more detailed description of the parameters please type 
% "help perform_nl_means" into Matlabs command prompt. The parameter "h" is
% denoted as "k" and teh parameter "N" is denoted as "T".
% 
%
% OUTPUTS:
% Y                     - a grey-scale image processed with the non-local
%                         means normalization technique
%                         
%
% NOTES / COMMENTS
% This function applies the non-local-means-based normalization to the
% grey-scale image X. 
%
% The function was tested with Matlab ver. 7.5.0.342 (R2007b).
%
% 
% RELATED FUNCTIONS (SEE ALSO)
% histtruncate     - a function provided by Peter Kovesi
% normalize8       - auxilary function
% perform_nl_means - a function provided by Gabriel Peyre
% 
% 
% ABOUT
% Created:        26.8.2009
% Last Update:    26.8.2009
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

function Y = nl_means_normalization(X,h,N);

%% Parameter checking
Y=0;%dummy
if nargin == 1
    h = 50;
    N = 2;
elseif nargin == 2   
    N = 2;
elseif nargin >3
    disp('Error! Wrong number of input parameters.')
    return;
end

%% Init. operations
X=normalize8(X);
options.T=h;
options.k=N;

%% Apply non-local means using Gabriels toolbox
[M1,Wx,Wy,mask_copy] = perform_nl_means(double(X), options);

%% Produce reflectance
R=log(double(X)+1)-log(M1+1);

%% Do some final post-processing (or not)
Y = normalize8(histtruncate(R,0.2,0.2));
   


