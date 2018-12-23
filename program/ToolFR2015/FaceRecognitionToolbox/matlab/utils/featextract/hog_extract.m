hog = feat;

[rows,cols,ch] = size(img);
if ch == 3; img = rgb2gray(img); end
resizedImg = imresize(img, [hog.width hog.width]);
crop = round(hog.cropBorder + hog.width*hog.cropFraction - hog.cropExtra);
resizedImg = resizedImg(1+crop(2):end-crop(4),1+crop(1):end-crop(3));
if hog.normalize
    resizedImg = normImg(histeq(uint8(round(resizedImg))),0,127,1);
end

%imagesc(resizedImg), axis image, colormap gray, drawnow

descI = hogfeatures(double(repmat(resizedImg,[1,1,3])), hog.gridCell);
cropImg = descI(:) ./ (norm(descI(:))+eps);

if hog.pyramid
	resizedImg = imresize(resizedImg, size(resizedImg) ./ 2);
	if hog.normalize
		resizedImg = normImg(histeq(uint8(round(resizedImg))),0,127,1);
	end
	descI = hogfeatures(double(repmat(resizedImg,[1,1,3])), hog.gridCell ./ 2);
	cropImg = [cropImg; descI(:) ./ (norm(descI(:)) + eps)];
end

cropImg = cropImg ./ (norm(cropImg) + eps);

featureVec = cropImg(:);


% img = uint8(img);
% 
% [rows,cols,ch] = size(img);
% if ch == 3; img = rgb2gray(img); end
% resizedImg = imresize(img, [96 96]);
% %crop = [6 6 4 1]*3 + 96*1/8 - 8*1; %newcrop
% %crop = [6 6 4 1]*3 + 96*1/8 - 8*0; %newcrop 2
% crop = [6 6 4 2]*3 + 96*1/8 - 8*2; %newcrop 2
% resizedImg = resizedImg(1+crop(2):end-crop(4), crop(1):end-crop(3));
% if 1
% 	resizedImg = normImg(histeq(resizedImg),0,127,1);
% end
% %descI = hogp(double(resizedImg));
% %descI = hogp(double(resizedImg), 8, 9, 10);
% descI = hogfeatures(double(repmat(resizedImg,[1,1,3])), 8);
% % 							MaxHistVal = 0.2;
% % 							descI = descI ./ repmat(sqrt(sum(descI.^2)+eps), [size(descI,1),1]);
% % 							descI = min(descI, MaxHistVal);
% % 							descI = descI ./ repmat(sqrt(sum(descI.^2)), [size(descI,1),1]);
% cropImg = descI(:) ./ (norm(descI(:))+eps);
% 
% if 1
% 	simg = imresize(resizedImg, size(resizedImg) ./ 2);
% 	if 1
% 		resizedImg = normImg(histeq(resizedImg),0,127,1);
% 	end
% 	%descI = hogp(double(resizedImg));
% 	%descI = hogp(double(resizedImg), 8, 9, 10);
% 	descI = hogfeatures(double(repmat(resizedImg,[1,1,3])), 8);
% % 								MaxHistVal = 0.2;
% % 								descI = descI ./ repmat(sqrt(sum(descI.^2)+eps), [size(descI,1),1]);
% % 								descI = min(descI, MaxHistVal);
% % 								descI = descI ./ repmat(sqrt(sum(descI.^2)), [size(descI,1),1]);
% 	cropImg = [cropImg; descI(:) ./ (norm(descI(:)) + eps)];
% end
% 
% cropImg = cropImg ./ (norm(cropImg) + eps);
% 
% featureVec = cropImg(:);