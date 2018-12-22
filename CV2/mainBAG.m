
NCL=10;%number of classes (10 VOC2006, 15 Scene dataset)
Ncluster=10;%number of times that the clustering approach is performed
DIMfeat=604;%dimensionality of the descriptor, 604 is uniform LTP

%mapping for LTP feature extraction
mapping1=getmapping011(8,'u2');
mapping2=getmapping011(16,'u2');


%PROJECTION MATRIX CREATION
patch=creaPCAltp(250000,DIMfeat,str,elenco,NCL);
mat_proiezione=pca(dataset(patch),0.98); %projection matrix

I1=adapthisteq(I1);%pre-processing

%resize of the immage
if min(size(I1))<50
    dim=50/min(size(I1));
    I1=imresize(I1,[size(I1,1)*dim  size(I1,2)*dim]);
end


%REGION EXTRACTION. Each object image is divided into subwindows,
%and a set of texture features S is extracted from these subwindows
step1=size(I1,1)/DIM;%. Each image is divided into overlapping sub-windows whose size is specified as percentage of the original image
step2=size(I1,2)/DIM;
passo=min([step1 step2]./2);
descr1=[];
for a=1:passo:size(I1,1)-step1-1
    for b=1:passo:size(I1,2)-step2-1
        T=I1(a:a+step1,b:b+step2);
        descr1=[descr1; [tesi(T,[3 ],8,'ci',1,0,0,mapping1,'nh') tesi(T,[ 3],16,'ci',2,0,0,mapping2,'nh')]];%here we have used LTP, you can use the other descriptors
        %if you use LPQ simply use: descr1=[descr1; [ lpqMIO(T, 5)']'];
        
        %to divide the image in four regions, useful for the second method
        %for codebook assegnation
        if a<size(I1,1)/2
            if b<size(I1,2)/2
                reg=1;
            else
                reg=2;
            end
        else
            if b<size(I1,2)/2
                reg=3;
            else
                reg=4;
            end
        end
        MEMORIZZOtr{t}{sotto}=uint8(reg);
        sotto=sotto+1;
        MAPPAreg{t}(sottoY,sottoX)=reg;
        sottoY=sottoY+1;
    end
    sottoX=sottoX+1;
end

%REGIONE EXTRACTION USING SIFT
[frames,descriptors,gss,dogss]=sift( I1, 'Verbosity', 0 );
descr1=descriptors';


%projection using the subspace matrix obtained in the step
%"PROJECTION MATRIX CREATION"
descr1=+(mat_proiezione*dataset(descr1));

FEAT{t}=descr1';%to store the descriptor of the t-th image, notice that we saved the cell array separately for each class
% save(strcat('C:\MATLAB1\DATA\voc2006_trainval\LPQ_',elenco{class},'.mat'),'FEAT')%where elenco{class} is the ID of a given class
%obviously there is a .mat for each descriptor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Codebook Creation using Ncluster different clusterings
%Let us suppose that FEAT contains the descriptors for all the training
%images of the class
for class=1:NCL
    load(strcat('C:\MATLAB1\DATA\voc2006_trainval\LPQ_',elenco{class},'.mat'),'FEAT');%to load the cell array that contains the descriptors of the class with ID elenco{class}
    %obviously there a .mat for each descriptor

    for passo1=1:Ncluster%for each clustering and for each block of NIMG images a codebook is built

        centri=[];%to store the centres of the clusters
        for cl=1:NIMG:length(FEAT)%for each NIMG images of this class
            t=1;

            O=single(zeros(length((FEAT{1}(:,1))),200000));%to stores the patches
            for i=cl:min([cl+NIMG length(FEAT)]);
                for ip=1:size(FEAT{i},2)
                    O(:,t)=FEAT{i}(:,ip);%to stores the patches
                    t=t+1;
                end
            end
            O(:,t:200000)=[];

            %to run K-Means
            k=(rand(1)*30)+10; %random number of clusters
            [Classes,Centres]=dcKMeans(O',k);
            centri=[centri; Centres];%the centres are concatenated
        end

        CLUSTER{class}{passo1}=centri;%to store the centers of the clusters of the given class

    end
end


%CODEBOOK ASSEGNATION - FIRST METHOD
%to create the histogram that represents an image
%Let us define ImgDESCR the matrix that contains the descriptors for all
%the regions of a given image 

%the histogram is calculated separately for each clustering (1:Ncluster)
po=1;
for cl=1:NCL%for all the clusters of all the classes
    centri=CLUSTER{cl}{passo1};%clusters of the class "cl" and passo1-th clustering
    D=distm(ImgDESCR',centri);
    [a,b]=min(D');%to assign each region to a cluster
    %building the histogram
    for p=1:size(centri,1)
        FE(id,po)=sum(b==p);%id is the number of the image
        po=po+1;
    end
end

%we store the histograms of the training images in FE
%we store the histograms of the test images in FEtest

%histogram normalization, normalization to sum 1
for i=1:size(FE,1)
    FE(i,:)=FE(i,:)./sum(FE(i,:)+0.00001);
end
for i=1:size(FEtest,1)
    FEtest(i,:)=FEtest(i,:)./sum(FEtest(i,:)+0.00001);
end


%here run the classification by SVM, training with FE, test set is FEtest



%CODEBOOK ASSEGNATION - SECOND METHOD
%the histogram is calculated separately for each clustering (1:Ncluster)
po=1;
for cl=1:NCL%for all the clusters of all the classes
    centri=CLUSTER{cl}{passo1};%clusters of the class "cl" and passo1-th clustering
    ImgDESCR=ImgDESCR';
    for regione=1:4%each image is divided in four equal regions and separately for each region a different codebook assignation is performed.
        clear INF
        for ind=1:size(ImgDESCR,1)
            INF(ind)=MEMORIZZOtr{j}{ind}==regione;
        end
        ImgDESCR=ImgDESCR(find(INF),:);%descriptors of the patches that belong to the region "regione"
        Dtr=distm(ImgDESCR,centri);
        [a,b]=min(Dtr');%to assign each region to a cluster

        H=reshape(b,[max(unique(sum(MAPPAreg{j}==regione,2))) max(unique(sum(MAPPAreg{j}==regione)))]);

        NH=HistContext(H);%it encodes each region a 30 dimensional feature vector
        for p=1:length(NH)
            FE(id,po)=NH(p);%id is the number of the image
            po=po+1;
        end

    end
end



