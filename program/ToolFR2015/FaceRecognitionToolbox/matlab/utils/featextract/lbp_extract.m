lbp = feat;

resizedImg = imresize(img, [lbp.width lbp.width]);
crop = round(lbp.cropBorder + lbp.width*lbp.cropFraction - lbp.cropExtra);
resizedImg = resizedImg(1+crop(2):end-crop(4),1+crop(1):end-crop(3));
if lbp.normalize
	resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
end
[descI, lbpImg] = lbpfeature(resizedImg, lbp.gridsX, lbp.gridsY);
cropImg = descI(:) ./ norm(descI(:) + eps);

if lbp.pyramid
	resizedImg = imresize(resizedImg, size(resizedImg) ./ 2);
	if lbp.normalize
		resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
	end
	[descI, lbpImg] = lbpfeature(resizedImg, lbp.gridsX, lbp.gridsY);
	cropImg = [cropImg; descI(:) ./ norm(descI(:) + eps)];
end

featureVec = cropImg(:);