
clear all


% original parameters L=5,m=3,w=7,n=8
%
% 
%  size block (radius==L/2): L = {5,6,12}
%  number of  orientation : m = {2,4,7}
%  cell size : w={4,6,8}
%  neighbors: n={6,9,12}


%perturbation of the parameters
tmp=1;
COMB(tmp,:)=[5 3 7 8];tmp=tmp+1;
for L=[6 12]
    COMB(tmp,1)=L;
    COMB(tmp,2:4)=[3 7 8];
    tmp=tmp+1;
end

for m=[2 4 7]
    COMB(tmp,2)=m;
    COMB(tmp,[1 3:4])=[5 7 8];
    tmp=tmp+1;
end

for w=[4 6 8]
    COMB(tmp,3)=w;
    COMB(tmp,[1:2 4])=[5 3 8];
    tmp=tmp+1;
end

for n=[6 9 12]
    COMB(tmp,4)=n;
    COMB(tmp,[1:3])=[5 3 7];
    tmp=tmp+1;
end

%%%% FERET PROTOCOL %%%%
aggiorno=1;
for qualeCOMB=[1:2 5:12]

    % variables initialisation of Poem

    nbOri=COMB(qualeCOMB,2);
    gradType=0; % type of mask used for calculating the gradient image:
    % =0: defaut function of Matlab
    % =1: the mask defined by gradConv
    gradConv=[-1 0 1];

    kerConv=fspecial('gaussian',COMB(qualeCOMB,3),COMB(qualeCOMB,3)); % defining cell where hog is calculated;
    % here 'first 7' is cell size and gaussian filter
    % is used (although this, kerConv is
    % nearly uniform)
    radius=COMB(qualeCOMB,1);  % radius of block where lbp is applied
    neighbors=COMB(qualeCOMB,4);  % nb of neighbors per cell
    mapping=getmapping(neighbors,'u2');
    numBlk=8;   % number of image blocks divided per direction for calculating histogram of POEM
    signMode=0;  % =0 unsigned
    softQuantizationMode=1;  % = 0 hard; =1 soft quantization
    outMode=1;               % = 0 POEM images; =1 POEM-HS where numBlk parameter is taken into account for calculating


    for metodo=1:3%diversi enhancement

        % % 1) read img training
        fid=fopen('d:\data\FERET\FERET_1_training.txt','r');
        NumIMG=fscanf(fid,'%f',1);
        str='d:\data\FERET\';
        strCROP='d:\data\FERETcrop\';

        % 2) save Poem ed Id volto
        X=[];
        for imgTR=1:NumIMG
            id=fscanf(fid,'%f',1);
            label(imgTR)=id;
            fscanf(fid,'%f',1);
            nameFile=fscanf(fid,'%s',1);
            nameFile(length(nameFile)-3:length(nameFile))='.tif';
            VOLTO=imread(strcat(strCROP,nameFile));

            %different enhancement apporaches
            if  metodo==1
                VOLTO = adaptive_single_scale_retinex(VOLTO,15);
            elseif metodo==2
                VOLTO = anisotropic_smoothing(VOLTO);
            elseif metodo==3
                VOLTO = dog(log(single(VOLTO)+1));
            end

            % 3) extract Poem
            poem=single(POEM(VOLTO, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping, numBlk, signMode, softQuantizationMode, outMode));
            poem=sqrt(poem);
            poem=(poem-mean(poem))/std(poem);
            descrPOEMtr{imgTR}=poem;

            X=[X; poem];
        end
        fclose(fid)

        %calculating whitened PCA
        X=X';
        whos X
        N=size(X,2);
        m=mean(X,2);
        for i=1:N
            X(:,i)=double(X(:,i)) - m;
        end
        L=(X'*X)/N;

        [V D] = eig(L);  % L*V = D*V
        [eigVecs eigVals] = sortem(V,D);
        clear V
        clear D
        clear L

        %Eigenvectors of C matrix
        u=[];
        for i=1:size(eigVecs,2)
            if eigVals(i,i)>10e-4
                temp=eigVals(i,i);
                u=[u (X*eigVecs(:,i))./temp];  % normalization for whitened PCA
            end
        end

        PPOEM=u(:,1:500);
        X=PPOEM'*X;
        meanAllPOEM=m;

        for imgTR=1:NumIMG
            descrPOEMtr{imgTR}=X(:,imgTR);
        end

        %4) read img testing
        labelTE=single(zeros(4,1195));
        for testSET=1:4

            fid=fopen(strcat(str,'FERET_',int2str(testSET),'_testing.txt'),'r');
            NumIMG(testSET)=fscanf(fid,'%f',1);

            for imgTEST=1:NumIMG(testSET)

                nameFile=fscanf(fid,'%s',1);
                nameFile(length(nameFile)-3:length(nameFile))='.tif';
                VOLTO=imread(strcat(strCROP,nameFile));

                if  metodo==1
                    VOLTO = adaptive_single_scale_retinex(VOLTO,15);
                elseif metodo==2
                    VOLTO = anisotropic_smoothing(VOLTO);
                elseif metodo==3
                    VOLTO = dog(log(single(VOLTO)+1));
                end

                id=fscanf(fid,'%f',1);
                labelTE(testSET,imgTEST)=id;

                poem=single(POEM(VOLTO, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping, numBlk, signMode, softQuantizationMode, outMode));
                poem=sqrt(poem);
                poem=(poem-mean(poem))/std(poem);
                poem=poem';
                poem=poem-meanAllPOEM;
                poem=PPOEM'*poem;

                descrPOEMtest{testSET}{imgTEST}=poem';
            end

            fclose(fid)

        end

        %5) save

        % save(str,'DatiwPOEMFERET.mat','label','descrPOEMtr','descrPOEMtest','labelTE','NumIMG')
        % clear all
        %
        % load('C:\Users\Claudia\Desktop\TESI\SaveMat\DatiFERET.mat')
        % %6) comparison with training and testing

        t=1;

        nme{t}='eucdist';t=t+1;
        nme{t}='sqdist';t=t+1;
        nme{t}='dotprod';t=t+1;
        nme{t}='nrmcorr';t=t+1;
        nme{t}='corrdist';t=t+1;
        nme{t}='angle';t=t+1;
        nme{t}='cityblk';t=t+1;
        nme{t}='maxdiff';t=t+1;
        nme{t}='mindiff';t=t+1;
        nme{t}='intersect';t=t+1;
        nme{t}='intersectdis';t=t+1;
        nme{t}='chisq';t=t+1;
        nme{t}='kldiv';t=t+1;
        nme{t}='jeffrey';

        for dis=6

            distComparison=single(zeros(4,1195,1196));

            for testSET=1:4
                clear labelPres
                labelPres=single(zeros(1,NumIMG(testSET)));
                for imgTEST=1:NumIMG(testSET)
                    %comparison with training
                    for imgTR=1:1196
                        distComparison(testSET,imgTEST,imgTR)=slmetric_pw(descrPOEMtr{imgTR},descrPOEMtest{testSET}{imgTEST}',nme{dis});
                    end

                    [a,b]=min(distComparison(testSET,imgTEST,:));
                    labelPres(imgTEST)=label(b);

                end

                % error calculation
                ACCFeret(testSET)=sum(labelPres==labelTE(testSET,1:NumIMG(testSET)))/NumIMG(testSET);
            end
            ACCFeret
            %to save the distances
            scoreDIST1{aggiorno}=ACCFeret;
            scoreDIST2{aggiorno}=distComparison;
        end

        save('d:\data\DatiScorePPOEMFeret.mat','scoreDIST1','scoreDIST2')
        aggiorno=aggiorno+1;
    end
end

%to comsbine the different POEM we used sum rule



