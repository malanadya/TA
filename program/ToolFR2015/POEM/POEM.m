function [result]=POEM(varargin) %img, nbOri, gradType, gradConv, kerConv, radius, neighbors, mapping, numBlk, signMode, softQuantizationMode, outMode


% parameter checking---------not finished
error(nargchk(1,12,nargin));
img=double(varargin{1});

if nargin==1
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
else

nbOri=varargin{2};
gradType=varargin{3};
gradConv = varargin{4};
kerConv=varargin{5};
radius=varargin{6};
neighbors=varargin{7};
mapping=varargin{8};
numBlk=varargin{9};
signMode=varargin{10}; 
softQuantizationMode=varargin{11};
outMode=varargin{12};
%img=imresize(img,[110 110]);
end


if gradType == 0
    [fx, fy] = gradient(img);
else    
    fx = conv2(img,gradConv,'same');
    fy = conv2(img,gradConv','same');
end

grad = (fx.^2 + fy.^2);
grad = grad.^0.5;
%grad=max(grad,0.5);



if signMode==0  %unsigned
    orient = atan2(fy,fx);
    orient = (orient<0)*pi + orient;
    
    if softQuantizationMode==0 %hard
        orient = ceil(orient/pi*nbOri)-1;
        orient = mod(orient,nbOri);
    else
        mag=soft_assign(orient,grad,nbOri,0);
    end
else
    %%
end


for i=0:nbOri-1
    if softQuantizationMode==0
        orientI = (orient==i);
        tmp = grad.*orientI;
        tmp = conv2(tmp,kerConv,'same');
    else
        tmp = mag(:,:,i+1);
        tmp = conv2(tmp,kerConv,'same');
                
    end
       
%         tmp2=max(tmp2,1);
%         tmp=tmp1./tmp2;
        %tmp = max(tmp,2);
        
    if outMode==1
        tmp2 = lbp(tmp,radius,neighbors,mapping,'h',numBlk);  
    else
        tmp2 = lbp(tmp,radius,neighbors,mapping,'i');
    end 

    if outMode==1
        if i==0        
            hist = tmp2;
          
        else
            hist = [hist tmp2];
        end
    else
        if i==0
            gradList=tmp2;
        else
            gradList(:,:,i+1) = tmp2;
        end    
    end  
end

if outMode==1
    result=hist;
else
    result=gradList;
end