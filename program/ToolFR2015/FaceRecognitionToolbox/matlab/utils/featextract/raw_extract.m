
raw = feat;
[h,w,c] = size(img);
if c ~= 1
    img = rgb2gray(img);
end
n = norm(img);
if n < eps
    img = rand(size(img));
    n = norm(img);
end
img = img ./ n;
featureVec = img(:);