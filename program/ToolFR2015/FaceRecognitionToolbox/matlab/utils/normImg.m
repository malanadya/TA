function nimg = normImg(img, ustd, um, subtractPlane)
	warning off;
	[rows, cols] = size(img);
	if ~exist('um', 'var')
		um=127;
	end
	if ~exist('ustd', 'var')
		ustd = 127/6;
	end
	if ~exist('subtractPlane', 'var')
		subtractPlane = 0;
	end
	
	if subtractPlane
		s = size(img);
		B = double(reshape(img, s(1)*s(2), 1));
		B = (B - mean(B));
		[X,Y] = meshgrid(1:s(1),1:s(2));
		X = X ./ s(1)-0.5;
		Y = Y ./ s(2)-0.5;
		A = double([reshape(X,s(1)*s(2),1) reshape(Y,s(1)*s(2),1)]);
		x = A\B;
		sub = reshape(A*x,s(1),s(2));
		img = uint8(double(img) - sub);
	end
	
	if ustd == 0
		%m=mean(double(img(:)));
		%nimg = img + uint8(-double(m)+um);
		%temp=reshape(double(img), rows*cols,1);
		%m=mean(temp);
		%nimg = uint8(reshape((temp-m)*1/1+um,rows,cols));
		nimg = img + (um - mean(img(:)));
	else
		temp=reshape(double(img), rows*cols,1);
		m=mean(temp);
		st=std(temp);
		nimg = uint8(reshape((temp-m)*st/ustd+um,rows,cols));
	end
	
	%nimg=uint8(reshape((temp-m)*1/1+um,rows,cols));