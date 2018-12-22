function MFS = HarrisMFS( image )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exact Harris features from input image 
% 
% input:
%   image: input image for feature extraction.
%   
% output:
%   MFS: Multi-fractal Spectrum feature to represent image
%
% Written by Huang Sibin
% Update in 2012.1.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% the image parameters
im=double(image);
%Using [1..256] to denote the intensity profile of the image
GRAY_BOUND =[1, 256];
im = GRAY_BOUND(1)+ (GRAY_BOUND(2)-GRAY_BOUND(1)) * ...
    (im - min(im(:)))/(max(im(:))-min(im(:)));
[row,col] = size(im); 

%% Derivative of image 
dx = [-1 0 1; -1 0 1; -1 0 1];
dy = dx';
load gauss.mat gauss_mask;
%% Scale space decomposition
for i=1:length(gauss_mask)
    L_img{i}= conv2(im,gauss_mask{i},'same');
    Lx = conv2(L_img{i},dx,'same');
    Ly = conv2(L_img{i},dy,'same');
    M(i,:,:)= Lx.^2 .* Ly.^2 - (Lx.*Ly).^2- 0.04*((Lx +Ly).^2);
end
%% form image scale invariant image
[v_M,idx_M]=max(abs(M));
scale_M = reshape(idx_M,size(im));
M_img = zeros(row,col);
for j=1:length(gauss_mask)
    M_img = M_img +L_img{j}.*(scale_M == j);
end
%% MFS calculation
MFS=CombineTmpl(M_img);
