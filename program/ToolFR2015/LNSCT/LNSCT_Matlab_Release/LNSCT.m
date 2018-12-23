function u=LNSCT(I)
%% A demos to use NSCT to extract the illumination-invariant facial features
% Key functions:
% [1]EstimateNoiseVarianceOfNSCT
% [2]EstimationAlbedoUsingNSCT_PicImage
% [3]nsctdec
% [4]nsctrec
% Please use the thresholded v as facial feature for recognition
%--------------------Parameter setting----------------
length=100; %the length of face image
width=100;  %the width of face image
levels=[3 4 4];% numbers of directions in different scales. [3 4 4] means use [2^3, 2^4, 2^4] directions in three scales.
dfilt= 'dmaxflat7'; % filter for decomposition
pfilt='maxflat'; % filter for reconstruction
lamda=0.003;% scale shreshod
% ch=0.001;% for the noisy image
%-------------------------------------------------------------
%% Estimating the Variance of NSCT
% disp('Estimating or loading the Variance of NSCT---------------------------');
% t0=cputime;
%nvar_Monto_Carlo=EstimateNoiseVarianceOfNSCT(length,width,pfilt,dfilt,levels);
load nvar_Monto_Carlo; % you can use the above function to estimate this again
% t=cputime-t0;
% fprintf('Finish! spend %d s\n',t);
% 
% % Read face image
% disp('Decompose a face image- - - - -');
% I=imread('face.bmp');
% subplot(1,3,1);imshow(I);

%% LNSCT
I = double(I);   
I(find(I==0))=1;
I=log(I);
v=EstimationAlbedoUsingNSCT_PicImage(I,levels,lamda,nvar_Monto_Carlo,dfilt,pfilt );% for the noise-free image
% v=EstimationAlbedoWithNoiseUsingNSCT_PicImage(I,levels,lamda,ch,nvar_Monto_Carlo,dfilt, pfilt);%for the noisy image
v(find(v<-1.2))=-1.2;% suggestion
v(find(v>1.2))=1.2;% suggestion
u=I-v;

% %% show result
% subplot(1,3,2);imshow(mat2gray(exp(v)));
% subplot(1,3,3);imshow(mat2gray(exp(u)));