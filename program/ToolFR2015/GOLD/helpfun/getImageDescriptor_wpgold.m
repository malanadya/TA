function [wpgold] = getImageDescriptor_wpgold(model, im, gradIMG, masch)
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
if nargin>2
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
        % Vectorize projection
        triu_matrix = logical(triu(ones(size(sel_descrs,1),size(sel_descrs,1)),1));
        cov_ts1 = cov_ts(triu_matrix).*(2^0.5);    
        cov_ts2 = cov_ts(logical(eye(size(sel_descrs,1))));
        % Concatenate mean and projected covariance
        gold = [mean_sel_descrs; cov_ts1; cov_ts2];
        gold = gold(:);
        % Power normalization
        gold = sign(gold).*abs(gold).^0.5;
        % L2 normalization
        gold = gold / norm(gold,2);
        golds{ii} = gold;
    end
    % Generate the final pyramidal descriptor
    wpgold=[wpgold; cat(1,golds{:})];
end
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


