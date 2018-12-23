
clear ;
close all;

RGB = imread('94.jpg');
tic;
smap = SaliencyMap_MCS(RGB,[64 64]);
toc;
figure(1)
subplot(1,3,1),sc(RGB);
subplot(1,3,2),sc(smap);
subplot(1,3,3),sc(cat(3,smap,double(RGB(:,:,1))),'prob_jet');
