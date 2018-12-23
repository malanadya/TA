%PREX5 PRTOOLS example of image vector quantization
help prex5
echo on
		% standard Matlab TIFF read
girl = imread('girl.tif','tiff');
		% display
figure
subplot(2,3,1);
subimage(girl); axis off;
title('Girl 1'); drawnow
		% construct 3-feature dataset from entire image
g1 = im2feat(girl);
		% generate testset
t = gendat(g1,250);
		% run modeseek, find labels, and construct labeled dataset
labt = modeseek(t*proxm(t),25);
t= dataset(t,labt);
		% train NMC classifier
w = t*qdc([],1e-6,1e-6);
		% classify all pixels
pack
lab = g1*w*classim;
		% show result
		% substitute class means for colors
cmap = +meancov(t(:,1:3));
subplot(2,3,2);
subimage(lab,cmap);
axis off;
title('Girl 1 --> Map 1')
drawnow

		% Now, read second image

girl2 = imread('girl2.tif','tiff');
		% display
subplot(2,3,4);
subimage(girl2); 
axis off;
title('Girl 2'); drawnow
		% construct 3-feature dataset from entire image
g2 = im2feat(girl2);
clear girl girl2
pack
lab2 = g2*w*classim;
		% show result
		% substitute class means for colors
cmap = +meancov(t(:,1:3));
subplot(2,3,5); subimage(lab2,cmap);
axis off;
title('Girl 2 --> Map 1')
drawnow

		% Compute combined map

g = [g1; g2];
t = gendat(g,250);
labt = modeseek(t*proxm(t),25);
t= dataset(t,labt);
w = t*qdc([],1e-6,1e-6);
cmap = +meancov(t(:,1:3));
clear g
pack
lab = g1*w*classim;
subplot(2,3,3); subimage(lab,cmap);
axis off;
title('Girl 1 --> Map 1,2')
drawnow
pack
lab = g2*w*classim;
subplot(2,3,6); subimage(lab,cmap);
axis off;
title('Girl 2 --> Map 1,2')
drawnow
set(gcf,'DefaultAxesVisible','remove')
echo off
