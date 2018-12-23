tplbp = feat;

resizedImg = imresize(img, [tplbp.width tplbp.width]);
crop = round(tplbp.cropBorder + tplbp.width*tplbp.cropFraction - tplbp.cropExtra);
resizedImg = resizedImg(1+crop(2):end-crop(4),1+crop(1):end-crop(3));
if tplbp.normalize
    resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
end
[descI, lbpImg] = TPLBP(im2double(resizedImg), 'gridCellY', tplbp.gridCellY, 'gridCellX', tplbp.gridCellX);
if tplbp.reduceDims, descI = tplbpPCA.u(:,1:tplbp.reduceDims)'*descI; end
cropImg = descI(:);

if tplbp.pyramid
    resizedImg = imresize(resizedImg, size(resizedImg) ./ 2);
    if tplbp.normalize
        resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
    end
    [descI, lbpImg] = TPLBP(im2double(resizedImg), 'gridCellY', tplbp.gridCellY ./ 2, 'gridCellX', tplbp.gridCellX ./ 2);
	if tplbp.reduceDims, descI = tplbpPCA.u(:,1:tplbp.reduceDims)'*descI; end
    cropImg = [cropImg; descI(:)];
end

featureVec = cropImg(:);