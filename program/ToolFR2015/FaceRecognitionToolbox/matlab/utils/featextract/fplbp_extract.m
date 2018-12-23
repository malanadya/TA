fplbp = feat;

resizedImg = imresize(img, [fplbp.width fplbp.width]);
crop = round(fplbp.cropBorder + fplbp.width*fplbp.cropFraction - fplbp.cropExtra);
resizedImg = resizedImg(1+crop(2):end-crop(4),1+crop(1):end-crop(3));
if fplbp.normalize
    resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
end
[descI, lbpImg] = FPLBP(im2double(resizedImg), 'gridCellY', fplbp.gridCellY, 'gridCellX', fplbp.gridCellX);
cropImg = descI(:);

if fplbp.pyramid
    resizedImg = imresize(resizedImg, size(resizedImg) ./ 2);
    if fplbp.normalize
        resizedImg = normImg(histeq(uint8(resizedImg)),0,127,1);
    end
    [descI, lbpImg] = FPLBP(im2double(resizedImg), 'gridCellY', fplbp.gridCellY, 'gridCellX', fplbp.gridCellX);
    cropImg = [cropImg; descI(:)];
end

featureVec = cropImg(:);
