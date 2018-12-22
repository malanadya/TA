function Img2MFS( directory_name , image_format )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exact features from input images directory
% input:
%   directory_name: directory name of images
%   image_format: image format for input
%          e.g.   JPEG : 'jpg'
%                 PGM  : 'pgm'
%                 PNG  : 'png'
% output:
%   Mat file of the same directory
%
% 
%   This is the basic code of orientation template approach.
%   It's performance can be improved by combining different kinds of input
%   filter as show by comment.
%
% Written by Huang Sibin
% Update in 2012.1.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate the list of image name from directory
D = dir(fullfile(directory_name,['*.',image_format]));
FileNum = length(D);

for k = 1:FileNum,
    FileList{k} = D(k).name; 
end;
%% Extract feature from images.
for k = 1:FileNum,
    display(['Doing on ',FileList{k}]);
    im = imread([directory_name,'/',FileList{k}]);
    im=single(im);
    
    %Laplacian MFS
    MFS(k,:)=LapMFS(im);
    
    %intensity MFS
%     Int_MFS(k,:)=CombineTmpl(im);  
    
    %Gradient MFS
%     fx = 1/2*[-1,0,1];
%     fy = fx';
%     fxy = 1/2*[-1 0 0;0 0 0;0 0 1];
%     fyx = 1/2*[0 0 -1;0 0 0;1 0 0];
%     Grad_img = (conv2(im,fx,'same')).^2 + (conv2(im,fy,'same')).^2 + (conv2(im,fxy,'same').^2) + (conv2(im,fyx,'same').^2);
%     Grad_MFS(k,:)=CombineTmpl(Grad_img);
   
    %Harris MFS
%     Harris_MFS(k,:)=HarrisMFS(im);
    
end
%% Save image feature as a MAT file.
save([directory_name,'.mat'],'MFS');

