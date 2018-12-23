%data una matrice con tutti i descrittori dei keypoint dell'immagine
%estraggo GOLD e le sue componenti

%provare a descrivere matrice di covarianza mediante altri descrittori,
%magari può essere un modo per accoppiare due descrittori (e.g. lbp per
%keypoint poi LPQ su matrice ottenuta partendo da LBP

function [wpgold] = EstraggoGOLD(model, im, feat, map1, map2, ICAtextureFilters, gradIMG, masch)
% -------------------------------------------------------------------------

im = standarizeImage(im) ;
nr = size(im,1);
nc = size(im,2);
 
% get PHOW features
[frames, descrs] = vl_phow(im, model.phowOpts{:}) ;
descrs=double(descrs);
descrs= descrs/255.0;


y = frames(1,:);
x = frames(2,:);

%region based
if nargin>6
    val=zeros(length(x),1);
    for i=1:length(x)
        val(i)=gradIMG(x(i),y(i));
    end
    tolgo=find(val==masch);
    x(tolgo)=[];
    y(tolgo)=[];
    descrs(:,tolgo)=[];
end

pyramid =model.numSpatial;
wpgold =[];

% For every pyramid level
for s = 1:length(pyramid)
    nbinr=pyramid(s);
    nbinc=pyramid(s);
    
    % Initialize storage for descriptors
    for ii=1:nbinr*nbinc
        cell_descrs{ii}=[];
    end
    % Accumulate weighted descriptors in cells
    for ii=1:length(x)
        r=x(ii);
        c=y(ii);
        [index, weight] = bilinear_interpolation(r,c,nr,nc,nbinr,nbinc);
        if (s==1)
            idx=find(weight~=0);
            if ~isempty(idx)
                cell_descrs{1}(:,end+1) =  descrs(:,ii)* weight(idx);
            end
        else
            idx=find(index>0);
            for jj=1:length(idx)
                cell_descrs{index(idx(jj))}(:,end+1)= descrs(:,ii)* weight(idx(jj));
            end
        end
    end
    % Compute GOLD for every cell
    for ii=1:length(cell_descrs)
        % Get descriptors
        sel_descrs=cell_descrs{ii};
        % Estimate mean
        mean_sel_descrs = mean(sel_descrs,2);
        % Estimate covariance (and make it positive definite)
        cov_sel_descrs =  makeposdef(cov(sel_descrs'));
        % Project to the tangent space
        cov_ts = logm(cov_sel_descrs);
        % to extract feature extractor from cov_ts
        if feat==1
            AC2=[lpqNEW(cov_ts,3,1,3) lpqNEW(cov_ts,5,1,3)];
        elseif feat==2
            M = getMap();
            AC2= [cvtRICLBP(cov_ts,1,2,M)  cvtRICLBP(cov_ts,2,4,M)  cvtRICLBP(cov_ts,4,8,M) ];
            AC2(find(isnan(AC2)))=0;
        elseif feat==3
            P= [LCP(cov_ts, 1, 8, map1,'i', []); LCP(cov_ts, 2, 16, map2,'i', [])];
            P(find(isnan(P)))=0;
            P(find(isinf(P)))=0;
            AC2=P;
        elseif feat==4
            AC2=[EstraiHoG(single(cov_ts),[],5,6)];
        elseif feat==5
            AC2=WLDestrazione(single(cov_ts));
        elseif feat==6 | feat==10 | feat==11 | feat==12 | feat==13
            % normalized BSIF code word histogram
            AC2=bsif(single(cov_ts), ICAtextureFilters,'nh',0);
        elseif feat==7
            opt.bin = 28;                                      % Number of bins used to evaluate histograms in EMI computation
            opt.NoFeat = 6;                                    % number of low level features
            opt.DescrDim = (opt.NoFeat^2+opt.NoFeat)/2;        % dimension of the HASC descriptor
            img=cov_ts;
            %% Extracting Features (for each image)
            feat = GetFeatures(img, opt);
            
            %% Features Normalization (over all images)
            % If you want to calculate the EMI matrices over a set of images
            % Max Vector and Min Vector have to be calculated for each feature over all
            % images. If you have N images and d features, at the end you must have a Max and
            % Min vector of size 1 x d
            [feat,max_vector,min_vector] = GetFeatNormalization(feat, opt);
            
            %% Get Covariance descriptor
            CovVec = GetCovariance(feat);
            
            %% Get EMI descriptor
            EMIVec = GetEntropyMI(feat, max_vector, min_vector, opt);
            
            AC2 = [CovVec EMIVec];
            
        elseif feat==8
            AC2= HEp_functionPaxNOlbp(cov_ts,[]);
            
        elseif feat==9
            AC2= EstraiWAVE(cov_ts);
            
        end
    end
    % Generate the final pyramidal descriptor
    wpgold=[wpgold; AC2];
end

wpgold=wpgold(:);
end


function C = makeposdef(cov)
    min_eig_threshold =0.0001;
    sizeD=size(cov,1);
    D = 0.000000001*eye(sizeD, sizeD);
    cov_org = cov;
    while true
        min_eig = min(eig(cov));
        if (min_eig>min_eig_threshold)
            break;
        end
        cov = cov_org + D;
        D = D * 10;
    end
    C=cov;
end
 