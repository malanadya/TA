function feat=FEtool(I,metodo,mapping)

%feature extraction
%%%%%%%%%%%%%%%%%% HOG
if metodo==1
    if size(I,3)>1
        I=rgb2gray(I);
    end
    hog = struct;
    hog.type = 'hog';
    hog.image.cropFraction = 0;
    hog.image.resizeWidth = 0;
    hog.image.cropBorder = [0 0 0 0];
    hog.pyramid = 1;
    hog.normalize = 1;
    hog.gridCell = 8;
    hog.pyramid = 0;
    descI = hogfeatures(double(repmat(I,[1,1,3])), hog.gridCell);
    cropImg = descI(:) ./ (norm(descI(:))+eps);
    if hog.pyramid
        resizedImg = imresize(I, size(I) ./ 2);
        if hog.normalize
            resizedImg = normImg(histeq(uint8(round(resizedImg))),0,127,1);
        end
        descI = hogfeatures(double(repmat(resizedImg,[1,1,3])), hog.gridCell ./ 2);
        cropImg = [cropImg; descI(:) ./ (norm(descI(:)) + eps)];
    end
    cropImg = cropImg ./ (norm(cropImg) + eps);
    feat = cropImg(:);
    
    
    %%%%%%%%%%%%%%%%%% LBP
elseif metodo==2
    if size(I,3)>1
        I=rgb2gray(I);
    end
    lbp = struct;
    lbp.type = 'lbp';
    lbp.pyramid = 1;
    lbp.normalize = 1;
    lbp.gridsX = round(10);
    lbp.gridsY = round(9);
    lbp.pyramid = 0;
    [descI, lbpImg] = lbpfeature(I, lbp.gridsX, lbp.gridsY);
    cropImg = descI(:) ./ norm(descI(:) + eps);
    if lbp.pyramid
        resizedImg = imresize(resizedImg, size(resizedImg) ./ 2);
        [descI, lbpImg] = lbpfeature(resizedImg, lbp.gridsX, lbp.gridsY);
        cropImg = [cropImg; descI(:) ./ norm(descI(:) + eps)];
    end
    feat = cropImg(:);
    
    %%%%%%%%%%%%%%%%%% POEM
elseif metodo==3
    if size(I,3)>1
        I=rgb2gray(I);
    end
    qualeCOMB=1;
    tmp=1;
    COMB(tmp,:)=[5 3 7 8];
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
    numBlk=8;   % number of image blocks divided per direction for calculating histogram of POEM
    signMode=0;  % =0 unsigned
    softQuantizationMode=1;  % = 0 hard; =1 soft quantization
    outMode=1;               % = 0 POEM images; =1 POEM-HS where numBlk parameter is taken into account for calculating
    feat=single(POEMdenseLBP(I, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping.table, numBlk, signMode, softQuantizationMode, outMode));
    feat=sqrt(feat);%non presente in LFW
    feat=(feat-mean(feat))/std(feat);
    
    %%%%%%%%%%%%%%%%%% Monogenic
elseif metodo==4
    %----------------------------------paramter name in the paper--
    minWaveLength       =  4;          %lambda_min
    sigmaOnf            =  0.64;       %miu
    mult                =  1.7;        %delta_ratio
    region_num          =  8;
    nscale              =  3;          %the number of scales
    bin_num_a           =  512;
    total               =  1024;
    phase_bin           =  4;
    bh_n                =  5;         %Mb
    bw_n                =  5;         %Mb
    sh_n                =  2;         %Mr
    sw_n                =  2;         %Mr
    neigh               =  8;
    radius              =  4;
    if size(I,3)>1
        I=rgb2gray(I);
    end
    feat=single(EstrarreMonogenetic(1, I,nscale, minWaveLength, mult, sigmaOnf,radius,neigh,bh_n,bw_n,sh_n,sw_n,bin_num_a,total));
    
    
    %%%%%%%%%%%%%%%%%% Monogenic
elseif metodo==5
    %----------------------------------paramter name in the paper--
    minWaveLength       =  4;          %lambda_min
    sigmaOnf            =  0.64;       %miu
    mult                =  1.7;        %delta_ratio
    region_num          =  8;
    nscale              =  3;          %the number of scales
    bin_num_a           =  512;
    total               =  1024;
    phase_bin           =  4;
    bh_n                =  5;         %Mb
    bw_n                =  5;         %Mb
    sh_n                =  2;         %Mr
    sw_n                =  2;         %Mr
    neigh               =  8;
    radius              =  4;
    if size(I,3)>1
        I=rgb2gray(I);
    end
    feat=single(EstrarreMonogenetic(2, I,nscale, minWaveLength, mult, sigmaOnf,radius,neigh,bh_n,bw_n,sh_n,sw_n,bin_num_a,total));
    
    
    
    %%%%%%%%%%%%%%%%%% Monogenic
elseif metodo==6
    %----------------------------------paramter name in the paper--
    minWaveLength       =  4;          %lambda_min
    sigmaOnf            =  0.64;       %miu
    mult                =  1.7;        %delta_ratio
    region_num          =  8;
    nscale              =  3;          %the number of scales
    bin_num_a           =  512;
    total               =  1024;
    phase_bin           =  4;
    bh_n                =  5;         %Mb
    bw_n                =  5;         %Mb
    sh_n                =  2;         %Mr
    sw_n                =  2;         %Mr
    neigh               =  8;
    radius              =  4;
    if size(I,3)>1
        I=rgb2gray(I);
    end
    feat=single(EstrarreMonogenetic(3, I,nscale, minWaveLength, mult, sigmaOnf,radius,neigh,bh_n,bw_n,sh_n,sw_n,bin_num_a,total));
    
    
    %%%%%%%%%%%%%%%%%% GOLD
elseif metodo==7
    % descriptor settings
    conf.numSpatial = [1 2] ;
    conf.svm.C = 10 ;
    conf.phowOpts = {'Step', 3} ;
    model.classes = 6 ;
    model.phowOpts = conf.phowOpts ;
    model.numSpatial = conf.numSpatial ;
    feat=getImageDescriptor_wpgold(model, I);
    
    %%%%%%%%%%%%%%%%%% HASC
elseif metodo==8
    
    feat=[];
    for SUBW1=1:8
        for SUBW2=1:8
            
            img=windowMIA(I,8,8,SUBW1,SUBW2);
            opt.bin = 28;                                      % Number of bins used to evaluate histograms in EMI computation
            opt.NoFeat = 6;                                    % number of low level features
            opt.DescrDim = (opt.NoFeat^2+opt.NoFeat)/2;        % dimension of the HASC descriptor
            if size(img,1)<6
                img(6,:)=0;
            end
            %% Extracting Features (for each image)
            fea = GetFeatures(img, opt);
            
            %% Features Normalization (over all images)
            % If you want to calculate the EMI matrices over a set of images
            % Max Vector and Min Vector have to be calculated for each feature over all
            % images. If you have N images and d features, at the end you must have a Max and
            % Min vector of size 1 x d
            [fea,max_vector,min_vector] = GetFeatNormalization(fea, opt);
            
            %% Get Covariance descriptor
            CovVec = GetCovariance(fea);
            
            %% Get EMI descriptor
            EMIVec = GetEntropyMI(fea, max_vector, min_vector, opt);
            
            feat = [feat CovVec EMIVec];
        end
    end
    
    feat(find(isinf(feat)))=0;
    
end