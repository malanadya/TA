clear all


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
    neighbors=8;  % nb of neighbors per cell
    mapping=getmapping(neighbors,'u2');
    numBlk=8;   % number of image blocks divided per direction for calculating histogram of POEM
    signMode=0;  % =0 unsigned
    softQuantizationMode=1;  % = 0 hard; =1 soft quantization
    outMode=1;               % = 0 POEM images; =1 POEM-HS where numBlk parameter is taken into account for calculating 
%poem=POEM(img, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping, numBlk, signMode, softQuantizationMode, outMode)











%base='C:\Documents and Settings\vu\Bureau\code\lfw data\lfw_1';
base='D:\work\code\dataset\new_crop_055_2eyes_group';
base='D:\work\code\dataset\new_crop_NorCut_06_2eyes_group';







sets{1}='fb';
sets{2}='fc';
sets{3}='dup1';
sets{4}='dup2';

training=1;

if training==0
directory=strcat(base,'/fa/');
dirCommand=strcat(directory,'*.bmp');
Files=dir(dirCommand);
PPOEM=[];
for k = 1:length(Files)
    if k>1
        fileNames(k)=struct('name',{Files(k).name});
    else
        fileNames=struct('name',{Files(k).name});
    end;
    
    InputName = Files(k).name;
    InputImage = imread(strcat(directory,InputName));
    poem = POEM(InputImage);      
    PPOEM=[PPOEM; poem];
end

save(strcat('mat_FERET\norcut_POEM.mat'),'PPOEM','fileNames');             
end


load(strcat('mat_FERET\norcut_POEM.mat'),'PPOEM','fileNames');             
    
    fid=fopen('result_poem_wiw_ori_feret.txt','a+');
    fprintf(fid,'\n norcut poem ');
    for iSet=3:3
        ret=0;
        directory=strcat(base,'/',sets{iSet},'/');
        dirCommand=strcat(directory,'*.bmp');
        Files=dir(dirCommand);
        kChi=[];
        kHei=[];
        for k = 1:length(Files)
            InputName = Files(k).name;
            InputImage = imread(strcat(directory,InputName));
            FeatureInput=POEM(InputImage);

            d=[];

            for i=1:size(fileNames,2)
                dist = dist_chi2(PPOEM(i,:),FeatureInput);
              d = [d dist];
            end
            
            [aa bb]=sort(d);    
    
            %InputName
            %fileNames(bb(1:10)).name
            for j=1:5 % face_yaleB0..
                str1(j)=fileNames(bb(1)).name(j);
                str2(j)=InputName(j);
            end;
            ret=ret+strcmp(str1,str2);
            if strcmp(str1,str2)==0
                kChi = [kChi k];      
            end
    
        end
        rate=ret/length(Files)
        fprintf(fid,'  %d \t',ret);
    end
fclose(fid);