function FinalS = SaliencyMap_MCS(RGB,s)

FinalS = zeros(size(RGB,1),size(RGB,2));
Lab = im2double(colorspace('Lab<-RGB',RGB));

for c = 1:3
    img = Lab(:,:,c);
    img = imresize(img, s, 'bilinear');    
    img = img - min(img(:));
    img = img/max(img(:));
    LSK{c} = Compute_LSK(img,3,0.008,1);
end
S = Compute_SelfRemblance(img,3,LSK);
FinalS = imresize(mat2gray(S),[size(RGB,1), size(RGB,2)],'bilinear');
end
