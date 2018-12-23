function [gaborFeatures] = gistGaborFeatures(img, filterBank)

for i=1:size(filterBank,1)
	evenFilterResponse = imfilter(img,filterBank{i,1},'symmetric','same','conv');
	oddFilterResponse = imfilter(img,filterBank{i,2},'symmetric','same','conv');

	gf = (sqrt(double(evenFilterResponse).^2 + double(oddFilterResponse).^2));
	gf = gf ./ max(gf(:));
	if i == 1
		gaborFeatures = gf;
	else
		gaborFeatures = [gaborFeatures gf];
	end

end

end