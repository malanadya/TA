% The toolbox used for deep features is available here http://www.vlfeat.org/matconvnet/
% For extracting the deep features you should download VGG-Face from http://www.vlfeat.org/matconvnet/models/vgg-face.mat

%Given an image im_
if size(im_,3)==1%The method works with color images
    im_(:,:,2)=im_;
    im_(:,:,3)=im_(:,:,1);
end

load('C:\Users\Nanni\Documents\MATLAB\Implementazioni\FaceRecognition2015\vgg-face.mat')
net.layers=layers;
net.normalization=meta.normalization;


%con nuovi .mat
cd X:\MATLAB1\TOOL\MatConvNet\matlab\src
im_ = single(im_);
im_ = imresize(im_, net.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus,im_,net.normalization.averageImage) ;
res = vl_simplenn(net, im_) ;
feat=[res(36).x(:); res(37).x(:)];%feature vector