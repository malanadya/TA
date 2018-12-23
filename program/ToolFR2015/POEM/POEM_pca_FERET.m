clear all

% Whitened PCA POEM for FR

% parameter setting
    nbOri=3;
    gradType=0; % type of mask used for calculating the gradient image: 
            % =0: defaut function of Matlab
            % =1: the mask defined by gradConv
    gradConv=[-1 0 1];
    
    kerConv=fspecial('gaussian',7,7); % defining cell where hog is calculated; 
                                  % here 'first 7' is cell size and gaussian filter
                                  % is used (although this, kerConv is
                                  % nearly uniform)
    radius=5;  % radius of block where lbp is applied
    neighbors=6;  % nb of neighbors per cell
    mapping=getmapping(neighbors,'u2');
    numBlk=8;   % number of image blocks divided per direction for calculating histogram of POEM
    signMode=0;  % =0 unsigned
    softQuantizationMode=1;  % = 0 hard; =1 soft quantization
    outMode=1;               % = 0 POEM images; =1 POEM-HS where numBlk parameter is taken into account for calculating 
%poem=POEM(img, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping, numBlk, signMode, softQuantizationMode, outMode);


%base='C:\Documents and Settings\vu\Bureau\code\lfw data\lfw_1';
base='D:\work\code\dataset\new_crop_NorCut_06_2eyes_group';
base='D:\work\code\dataset\new_crop_055_2eyes_group';

%test sets
sets{1}='fb';
sets{2}='fc';
sets{3}='dup1';
sets{4}='dup2';


training=0;

if training==0
% training phase
% extracting all feature vectors from the Fa reference set
directory=strcat(base,'/fa/');
dirCommand=strcat(directory,'*.bmp');
Files=dir(dirCommand);
X=[];
for k = 1:length(Files)
    if k>1
        fileNames(k)=struct('name',{Files(k).name});
    else
        fileNames=struct('name',{Files(k).name});
    end;
    
    InputName = Files(k).name;
    InputImage = imread(strcat(directory,InputName));

    poem=POEM(InputImage, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping, numBlk, signMode, softQuantizationMode, outMode);
    poem=sqrt(poem);    
    poem=(poem-mean(poem))/std(poem);
    X=[X; poem];
end


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

    
% trying several different PCA dimesions    
for numVecs=300:100:800
    PPOEM=u(:,1:numVecs);
    weightPOEM=PPOEM'*X;
    meanAllPOEM=m;
    save(strcat('mat_PCA_FERET\POEM_WPCAn_',num2str(numVecs),'.mat'),'PPOEM','weightPOEM','meanAllPOEM','fileNames');             
end

end % end of training


% testing phase
for numVecs=700:700
    load(strcat('mat_PCA_FERET\POEM_WPCAn_',num2str(numVecs),'.mat'),'PPOEM','weightPOEM','meanAllPOEM','fileNames');             
    fid=fopen('result_pcapoem_feret.txt','a+');
    fprintf(fid,'\n numVecs %d',numVecs);
    for iSet=1:2
        ret=0;
        directory=strcat(base,'/',sets{iSet},'/');
        dirCommand=strcat(directory,'*.bmp');
        Files=dir(dirCommand);
        wrongChi=[]; % test images with wrong recognition result
        for k = 1:length(Files)
            InputName = Files(k).name;
            InputImage = imread(strcat(directory,InputName));


            FeatureInput=POEM(InputImage, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping, numBlk, signMode, softQuantizationMode, outMode);
           
            FeatureInput=sqrt(FeatureInput);      
            FeatureInput=FeatureInput';
            FeatureInput=(FeatureInput-mean(FeatureInput))/std(FeatureInput);
            FeatureInput=FeatureInput-meanAllPOEM;
            FeatureInput_pca=PPOEM'*FeatureInput;
        
            d=[];
            for i=1:size(fileNames,2)
                dist = dist_cos(weightPOEM(:,i)',FeatureInput_pca');
                d = [d dist];
            end

            [aa bb]=sort(d);    

            for j=1:5 % face_yaleB0..
                str1(j)=fileNames(bb(1)).name(j);
                str2(j)=InputName(j);
            end;
            ret=ret+strcmp(str1,str2);
            if strcmp(str1,str2)==0
                wrongChi = [wrongChi k];      
            end
        end
        rate=ret/length(Files)
        fprintf(fid,'  %d\t',ret);
    end
fclose(fid);
end