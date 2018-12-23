
gabor = feat;

img = double(img);
%img = img ./ 255;
if gabor.includeImg
    finalImg = [img ./ max(img(:)) gistGaborFeatures(img, gaborFilterBank)];
    %finalImg = [img gistGaborFeatures(img, gaborFilterBank)];
else
    finalImg = [gistGaborFeatures(img, gaborFilterBank)];
end

featureVec = double(finalImg(:)) ./ norm(finalImg(:) + eps);