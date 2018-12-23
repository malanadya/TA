function [u v]=LTV(I,lamda)

%% Function
% Decompose image I based on LTV model: f=log(I)=v+u
% Reference:
% T. Chen et al. Total Variation Models for Variable Lighting Face Recognition, TPAMI 2006
%% Note:
% please install a Mosek software for supporting this code
% Mosek can be downloaded from:
% http://www.mosek.com/
%% Author
% Xiaohua Xie
% Sun Yat-sen University
% sysuxiexh@gmail.com

I=double(I);
M=max(max(I));
if M>100
    I(find(I<1))=1;
else
    I(find(I==0))=0.001;
end

f=log(I);
[u,v] = TV_L1_Model(f,lamda);

v(find(v<-1.5))=-1.5;
v(find(v>1.5))=1.5;
