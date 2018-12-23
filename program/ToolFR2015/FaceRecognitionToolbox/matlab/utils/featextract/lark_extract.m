
lark = feat;


resizedImg = imresize(img, [lark.width lark.width]);
crop = round(lark.cropBorder + lark.width*lark.cropFraction - lark.cropExtra);
resizedImg = resizedImg(1+crop(2):end-crop(4),1+crop(1):end-crop(3));
if lark.normalize
 	resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
%     resizedImg = resizedImg - min(resizedImg(:));
%     resizedImg = resizedImg/max(resizedImg(:));
end

larkImg = Compute_LSK(double(resizedImg),3,0.008,1);
featureVec = larkImg(:);

if lark.pyramid
	resizedImg = imresize(resizedImg, size(resizedImg) ./ 2);
	if lark.normalize
        resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
% 		resizedImg = resizedImg - min(resizedImg(:));
%         resizedImg = resizedImg/max(resizedImg(:));
	end
	larkImg = Compute_LSK(double(resizedImg),3,0.008,1);
	featureVec = [featureVec; larkImg(:)];
end