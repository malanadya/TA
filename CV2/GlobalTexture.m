%let us define I1 the image

%mapping for LTP
mapping1=getmapping011(8,'u2');
mapping2=getmapping011(16,'u2');
map1=getmapping011(8,'riu2');
map2=getmapping011(16,'riu2');


I1=adapthisteq(I1);%pre-processing


%to extract the saliency map from a given image I1
sal = gbvsIMG(I1,[],[],'C:\Users\nanni\Documents\MATLAB\MATLAB\TOOL\gbvs');
sal=sal.master_map_resized;%saliency map

% To extract the foreground image we simply label as foreground pixels each pixel which saliency is higher than a prefixed threshold TH. 
TH=0.15;
IMG=I1;
mask=sal.*0;%sal is the saliency map, we use it to initialize mask
mask(find(sal<TH))=0;
mask(find(sal>=TH))=1;%foreground pixels
IMG=IMG.*mask;
%to cut the background regions
R=find(sum(IMG,2)>10);
C=find(sum(IMG,1)>10);
I1=I1(R(1):R(length(R)),C(1):C(length(C)));%foreground image



%to divide the image in 5 regions
if regione==1
    IMG=window(I1,2,1,1,1);
elseif regione==2
    IMG=window(I1,2,1,2,1);
elseif regione==3
    IMG=window(I1,2,2,2,1);
elseif regione==4
    IMG=window(I1,2,2,2,2);
elseif regione==5
    D1=size(I1,1);D2=size(I1,2);
    IMG=I1(D1*0.25:D1*0.75,D2*0.25:D2*0.75);
end

%feature extraction from a generic image I1, each descriptor is saved in a cell array
FEAT{1}=[tesi(I1,[3 ],8,'ci',1,0,0,mapping1,'nh') tesi(I1,[ 3],16,'ci',2,0,0,mapping2,'nh')];%uniform LTP
FEAT{2}=lpqMIO(I1, 3)';%LPQ with M=3
FEAT{3}=lpqMIO(I1, 5)';%LPQ with M=5
FEAT{4}=[tesi(I1,[3 ],8,'ci',1,0,0,map1,'nh') tesi(I1,[ 3],16,'ci',2,0,0,map2,'nh')];%rotation invariant uniform LTP
FEAT{5}=EstraiHog(single(I1), [],3,3)';%histogram of gradient descriptor
FEAT{6}=single(mlhmsldp_spyr(I1));%Local derivative pattern 
FEAT{7}=single(LapMFS(I1));%Laplacian features
FEAT{8}=EstraiWAVE(I1);%Daubechies wavelets 

%before the feature extraction by gist we resize each image to a fixed
%dimension
I1=imresize(I1,[100 100]);

%parameters of GIST
conf.gist.extractFn            = @gist;
conf.gist.imageSize            = 256;
conf.gist.numberBlocks         = 4;
conf.gist.fc_prefilt           = 4;
conf.gist.outside_quantization = false;
conf.gistPadding.extractFn            = @gistPadding;
conf.gistPadding.numberBlocks         = 4;
conf.gistPadding.fc_prefilt           = 4;
conf.gist.G                    = createGabor([8 8 8 8], 100);
conf.gistPadding.imageSize            = [100 100];

FEAT{9}= gistGabor(prefilt(single(I1), conf.gist.fc_prefilt), conf.gist.numberBlocks, conf.gist.G);%GIST feature extraction





