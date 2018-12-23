[h,w,c] = size(img);

% Global options
try
    if opt.image.cropFraction > 0
        img = img(round(w*opt.image.cropFraction):w-round(w*opt.image.cropFraction),round(h*opt.image.cropFraction):w-round(h*opt.image.cropFraction),:);
    end
end
try
    if opt.image.resizeWidth > 0
        img = double(img);
        img = imresize(img, [opt.image.resizeWidth NaN]);
    end
end
try
    img = img(1+opt.image.cropBorder(2):end-opt.image.cropBorder(4),1+opt.image.cropBorder(1):end-opt.image.cropBorder(3),:);
end
try
    if opt.image.normalize
        img = normImg(histeq(uint8(img)),0,127,1);
    end
end

feedInImg = img;
finalOutVec = [];

if featExist && length(opt.features)
    doFeatLen = isempty(fbgFeatureLengths);
    % We can extract a bunch of features & append them
    for f = 1:length(opt.features)
        feat = opt.features{f};

        clear featureVec;
        img = feedInImg;
        
        try
            if opt.image.forceGrayscale && size(img,3) == 3
                img = rgb2gray(img);
            end
        end

        % Per feature options for image manipulation
        try
            if feat.image.cropFraction > 0
                img = img(round(w*feat.image.cropFraction):w-round(w*feat.image.cropFraction),round(h*feat.image.cropFraction):w-round(h*feat.image.cropFraction),:);
            end
        end
        try
            if feat.image.resizeWidth > 0
                img = double(img);
                img = imresize(img, [feat.image.resizeWidth feat.image.resizeWidth]);
            end
        end
        try
            img = img(1+feat.image.cropBorder(2):end-feat.image.cropBorder(4),1+feat.image.cropBorder(1):end-feat.image.cropBorder(3),:);
        end
        try
            if feat.image.normalize
                img = normImg(histeq(uint8(img)),0,127,1);
            end
        end

        img = double(img);

        % Extract features, append to current set
        eval(sprintf('%s_extract', feat.type));
        finalOutVec = [finalOutVec; featureVec(:)];

        if doFeatLen
            fbgFeatureLengths(f) = length(featureVec);
        end
    end
else
    finalOutVec = img(:);
end