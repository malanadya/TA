%PREX6 Use of images and eigenfaces
help prex6
echo on

if exist('face1.mat') ~= 2
	error('Face database not in search path')
end
a = readface([1:40],1);
w = klm(a);
imagesc(dataset(eye(39)*w',[],[],[],[],112)); drawnow
b = [];
for j = 1:40
	a = readface(j,[1:10]);
	b = [b;a*w];
end
figure
scatterd(b)
title('Scatterplot on first two eigenfaces')
fontsize(14)
featsizes = [1 2 3 5 7 10 15 20 30 39];
e = zeros(1,length(featsizes));
for j = 1:length(featsizes)
	k = featsizes(j);
	e(j) = testk(b(:,1:k),1);
end
figure
plot(featsizes,e)
xlabel('Number of eigenfaces')
ylabel('Error')
fontsize(14)
echo off
