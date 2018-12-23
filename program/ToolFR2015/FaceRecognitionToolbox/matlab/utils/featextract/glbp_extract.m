
glbp = feat;

resizedImg = imresize(img, [NaN glbp.width]);
crop = round(glbp.cropBorder + glbp.width*glbp.cropFraction - glbp.cropExtra);
resizedImg = resizedImg(1+crop(2):end-crop(4),1+crop(1):end-crop(3));
if glbp.normalize
	resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
end

finalImg = [resizedImg gistGaborFeatures(double(resizedImg), gaborFilterBank)];

resizedImg = finalImg;

[descI, lbpImg] = lbpfeature(im2double(resizedImg), glbp.gridsX*round(size(resizedImg,2)/size(resizedImg,1)), glbp.gridsY);
cropImg = descI;
featureVec = cropImg(:);

return;

% if glbp.includeImg
%     finalImg = [img ./ max(img(:)) gistGaborFeatures(img, gaborFilterBank)];
% else
%     finalImg = [gistGaborFeatures(img, gaborFilterBank)];
% end

%featureVec = finalImg(:);

resizedImg = imresize(img, [NaN glbp.width]);
crop = round(glbp.cropBorder + glbp.width*glbp.cropFraction - glbp.cropExtra);
resizedImg = resizedImg(1+crop(2):end-crop(4),1+crop(1):end-crop(3));
if glbp.normalize
	resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
end
[descI, lbpImg] = lbpfeature(im2double(resizedImg), glbp.gridsX, glbp.gridsY);
cropImg = descI(:);

if glbp.pyramid
	resizedImg = imresize(resizedImg, size(resizedImg) ./ 2);
	if glbp.normalize
		resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
	end
	[descI, lbpImg] = lbpfeature(im2double(resizedImg), glbp.gridsX, glbp.gridsY);
	cropImg = [cropImg; descI(:)];
end

featureVec = cropImg(:);