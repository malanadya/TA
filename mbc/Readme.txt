% ========================================================================
% Monogeic Binary Coding (MBC), Version 1.0
% Copyright(c) 2013  Meng YANG, Lei Zhang, Simon C.K. Shiu and David Zhang
% All Rights Reserved.
%
% ----------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is here
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.

%-------------------Demos---------------------------------------------------
Notes: 

Please copy the data in FERET to the folder "data" in each demo.
Please contact us for part of the FERET data we used in the paper.


demo_FERET_dup1_MBC_A.m   Face recognition demo on Dup1 of FERET by MBC_A (amplitude part)

demo_FERET_dup1_MBC_O.m   Face recognition demo on Dup1 of FERET by MBC_O (orientation part)

demo_FERET_dup1_MBC_P.m   Face recognition demo on Dup1 of FERET by MBC_P (phase part)

utilities : folder of MBC functions, including
compute_mbp_dup1_NEW:       function of computing similarity of samples
compute_similarity:         function of computing similarity of two (histogram) vector
construct_region_index:     functon of local regions' x and y coordinates
Count_Region_hist:          function of constructing the histogram descriptor of local regions
LearnFLD_New:               function of building Block-Fishier Linear Discrimination Projection
Fisherface_f_M_New:         functoin of computing fisher linear discrimination projection matrix
getmapping:                 function of local binary pattern (Marko Heikkil?and Timo Ahonen's code)
lbp:                        function of coding amplitude part (Marko Heikkil?and Timo Ahonen's code)
monofilt:                   function of Felsberg's monogenic representation of signal (Peter Kovesi's code)
lxp_phase:                  function of coding orientation or phase part
pw...:                      function of distance measurement (please see readme_of_pw)

%-------------------------------------------------------------------------
Please cite our following paper if you use the code:

Meng Yang, Lei Zhang, Simon C.K. Shiu, and David Zhang,"Monogenic Binary Coding: An efficient Local Feature Extraction Approach to Face Recognition", 
IEEE Trans. on Information Forensics and Security, vol. 7, no. 6, pp. 1738-1751, Dec. 2012.

%-------------------------------------------------------------------------
Contact: {yangmengpolyu@gmail.com};{cslzhang}@comp.polyu.edu.hk
