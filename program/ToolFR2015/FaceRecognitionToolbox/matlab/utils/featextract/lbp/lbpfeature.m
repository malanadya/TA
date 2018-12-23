function [descI,lbpImg] = lbp(img, x, y)
	lbpImg = lbp_image(double(img));
	off = 8;
	lbpImg = lbpImg(1+off:end-off,1+off:end-off);
	unipats = uniform_pattern(8)';
	np = size(unipats,1)+1;
	map = np*ones(2^8,1);
	map(1+unipats) = [1:np-1]';
	mapimg = map(1+lbpImg);
	descI = lbp_histo([1:np]',im2col(mapimg,[ceil(size(img,1)./y) ceil(size(img,2)./x)],'distinct'));

	% Normalize like FPLBP and TPLBP
	MaxHistVal = 0.2;
	descI = descI ./ repmat(sqrt(sum(descI.^2)), [size(descI,1),1]);
	descI = min(descI, MaxHistVal);
	descI = descI ./ repmat(sqrt(sum(descI.^2)), [size(descI,1),1]);
end