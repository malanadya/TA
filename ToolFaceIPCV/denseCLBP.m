% [S_hist, M_hist] = NEWdenseCLBP(I,R,N,MAPPING,MODE) returns densely sampled
%  complete local binary pattern histogram of an image I.
%  The CLBP codes are computed using N sampling points on a
%  circle of radius R and using mapping table defined by MAPPING.
%  See the getmapping function for different mappings and use 0 for
%  no mapping. Possible values for MODE are
%       'h' or 'hist'  to get a histogram of LBP codes
%       'nh'           to get a normalized histogram

% NOTE: The mean difference for thresholding (DiffThreshold) the CLBP magnitude
% component is estimated based on only to the neighborhoods' center sampling
% points that fall exactly on a pixel center.


%  Examples
%  --------
%       I=imread('rice.png');
%       mapping=getmapping(8,'u2');
%       [S_hist, M_hist]=NEWdenseCLBP(I,1,8,mapping,'h'); %CLBP histogram in (8,1) neighborhood
%                                               %using uniform patterns


function [S_hist, M_hist] = denseCLBP(varargin)
% Version 0.1
% Authors: Juha Ylioinas

% The implementation is based on the following sources:
% [1] http://www.cse.oulu.fi/CMV/Downloads/LBPMatlab
% [2] http://www4.comp.polyu.edu.hk/~cslzhang/code/CLBP.rar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parse input parameters (from [1])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

threshold = 0.015;
numBlk=0;
if (nargin >= 6)
    numBlk=varargin{6};
end

% Check number of input arguments.
error(nargchk(1,6,nargin));

image=varargin{1};
d_image=double(image);

if nargin==1
    spoints=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
    neighbors=8;
    mapping=0;
    mode='h';
end

if (nargin == 2) && (length(varargin{2}) == 1)
    error('Input arguments');
end

if (nargin > 2) && (length(varargin{2}) == 1)
    radius=varargin{2};
    neighbors=varargin{3};

    spoints=zeros(neighbors,2);

    % Angle step.
    a = 2*pi/neighbors;

    for i = 1:neighbors
        spoints(i,1) = -radius*sin((i-1)*a);
        spoints(i,2) = radius*cos((i-1)*a);
    end

    if(nargin >= 4)
        mapping=varargin{4};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end

    if(nargin >= 5)
        mode=varargin{5};
    else
        mode='h';
    end

end

if (nargin > 1) && (length(varargin{2}) > 1)
    spoints=varargin{2};
    neighbors=size(spoints,1);

    if(nargin >= 3)
        mapping=varargin{3};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end

    if(nargin >= 4)
        mode=varargin{4};
    else
        mode='h';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Start extracting LBPs (from [1] and [2] till row 202 )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine the dimensions of the input image.
[ysize xsize] = size(d_image);

miny=min(spoints(:,1));
maxy=max(spoints(:,1));
minx=min(spoints(:,2));
maxx=max(spoints(:,2));

% Block size, each LBP code is computed within a block of size bsizey*bsizex
bsizey=ceil(max(maxy,0))-floor(min(miny,0))+1;
bsizex=ceil(max(maxx,0))-floor(min(minx,0))+1;

% Coordinates of origin (0,0) in the block
origy=1-floor(min(miny,0));
origx=1-floor(min(minx,0));

% Minimum allowed size for the input image depends
% on the radius of the used LBP operator.
if(xsize < bsizex || ysize < bsizey)
    error('Too small input image. Should be at least (2*radius+1) x (2*radius+1)');
end

% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;

% Fill the center pixel matrix C.
d_C = d_image(origy:origy+dy,origx:origx+dx);

bins = 2^neighbors;

% Initialize the result matrix with zeros.
CLBP_S=zeros(dy+1,dx+1);
CLBP_M=zeros(dy+1,dx+1);

%Compute the LBP code image

for i = 1:neighbors
    y = spoints(i,1)+origy; x = spoints(i,2)+origx;
    % Calculate floors, ceils and rounds for the x and y.
    fy = floor(y); cy = ceil(y); ry = round(y);
    fx = floor(x); cx = ceil(x); rx = round(x);
    % Check if interpolation is needed.

    if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
        % Interpolation is not needed, use original datatypes
        d_N = d_image(ry:ry+dy,rx:rx+dx);
        D{i} = d_N >= d_C;
        Diff{i} = abs(d_N-d_C);
        MeanDiff(i) = mean(mean(Diff{i}));
    else
        % Interpolation needed, use double type images
        ty = y - fy;
        tx = x - fx;

        % Calculate the interpolation weights.
        w1 = (1 - tx) * (1 - ty) + eps('double'); %add eps to avoid rounding errors
        w2 =      tx  * (1 - ty) + eps('double');
        w3 = (1 - tx) *      ty  + eps('double');
        w4 =      tx  *      ty  + eps('double');

        % Compute interpolated pixel values
        N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
            w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);
        D{i} = N >= (d_C + threshold);
        Diff{i} = abs(N-d_C);
        MeanDiff(i) = mean(mean(Diff{i}));
    end
end

% Difference threshold for CLBP_M
DiffThreshold = mean(MeanDiff);

% Compute CLBP_S and CLBP_M
for i=1:neighbors
    % Update the result matrix.
    v = 2^(i-1);
    CLBP_S = CLBP_S + v*D{i};
    CLBP_M = CLBP_M + v*(Diff{i}>=DiffThreshold);
end

% Apply mapping if it is defined
if isstruct(mapping)
    bins = mapping.num;
    sizarray = size(CLBP_S);
    CLBP_S = CLBP_S(:);
    CLBP_M = CLBP_M(:);
    CLBP_S = mapping.table(CLBP_S+1);
    CLBP_M = mapping.table(CLBP_M+1);
    CLBP_S = reshape(CLBP_S,sizarray);
    CLBP_M = reshape(CLBP_M,sizarray);
end

result=CLBP_S;
if (numBlk>=1)
    if size(numBlk,2)==1
        k1=numBlk;
        k2=k1;
    else
        k1=numBlk(1);
        k2=numBlk(2);
    end


    [ysize xsize]=size(result);
    temp2=[];
    wR=floor(xsize/k1);
    hR=floor(ysize/k2);
    for i=1:k2
        y_start=(i-1)*hR+1;
        y_end=i*hR;
        if i==k2
            y_end=ysize;
        end
        for j=1:k1
            x_start=(j-1)*wR+1;
            x_end=j*wR;
            if j==k1
                x_end=xsize;
            end

            temp(:,:)=result(y_start:y_end,x_start:x_end);
            temp1=hist(temp(:),0:(bins-1));
            temp1=temp1/sum(temp1);

            %  temp1=normal_hist(temp1);
            temp2=[temp2 temp1];
            clear temp;
            clear temp1;
        end
    end

    result=temp2;
    clear temp;
    clear temp2;
end
S_hist = result;


result=CLBP_M;
if (numBlk>=1)
    if size(numBlk,2)==1
        k1=numBlk;
        k2=k1;
    else
        k1=numBlk(1);
        k2=numBlk(2);
    end

    [ysize xsize]=size(result);
    temp2=[];
    wR=floor(xsize/k1);
    hR=floor(ysize/k2);
    for i=1:k2
        y_start=(i-1)*hR+1;
        y_end=i*hR;
        if i==k2
            y_end=ysize;
        end
        for j=1:k1
            x_start=(j-1)*wR+1;
            x_end=j*wR;
            if j==k1
                x_end=xsize;
            end

            temp(:,:)=result(y_start:y_end,x_start:x_end);
            temp1=hist(temp(:),0:(bins-1));
            temp1=temp1/sum(temp1);

            %  temp1=normal_hist(temp1);
            temp2=[temp2 temp1];
            clear temp;
            clear temp1;
        end
    end

    result=temp2;
    clear temp;
    clear temp2;
end
M_hist = result;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ..some new lines of code to extract more LBPs -
%%% neighborhood's center visits pixel corners
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Check if dense sampling is possible
if(xsize > bsizex && ysize > bsizey)

    d_C = 0.25 * d_image(1:end-1,1:end-1) + ...
        0.25 * d_image(1:end-1,2:end) + ...
        0.25 * d_image(2:end,1:end-1) + ...
        0.25 * d_image(2:end,2:end);

    % Determine the dimensions of the input image.
    [ysize xsize] = size(d_C);

    % Calculate dx and dy;
    dx = xsize - bsizex;
    dy = ysize - bsizey;

    % Form the center pixel matrix d_C
    d_C=d_C(origy:origy+dy,origx:origx+dx);

    % Initialize the result matrix with zeros.
    CLBP_S=zeros(dy+1,dx+1);
    CLBP_M=zeros(dy+1,dx+1);

    for i = 1:neighbors

        % Adding 0.5 for both coordinates we end up to
        % the center of pixel corners
        y = spoints(i,1)+origy+0.5;
        x = spoints(i,2)+origx+0.5;

        % Calculate floors, ceils and rounds for the x and y.
        fy = floor(y); cy = ceil(y);
        fx = floor(x); cx = ceil(x);

        % Interpolation needed, use double type images
        ty = y - fy;
        tx = x - fx;

        % Calculate the interpolation weights.
        w1 = (1 - tx) * (1 - ty) + eps('double'); %add eps to avoid rounding errors
        w2 =      tx  * (1 - ty) + eps('double');
        w3 = (1 - tx) *      ty  + eps('double');
        w4 =      tx  *      ty  + eps('double');

        % Compute interpolated pixel values using the
        % original image (d_image)

        N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
            w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);

        D{i} = N >= (d_C + threshold);
        Diff{i} = abs(N-d_C);

    end

    for i=1:neighbors
        % Update the result matrix.
        v = 2^(i-1);
        CLBP_S = CLBP_S + v*D{i};
        CLBP_M = CLBP_M + v*(Diff{i}>=DiffThreshold);
    end

    % Apply mapping if it is defined
    if isstruct(mapping)
        bins = mapping.num;
        sizarray = size(CLBP_S);
        CLBP_S = CLBP_S(:);
        CLBP_M = CLBP_M(:);
        CLBP_S = mapping.table(CLBP_S+1);
        CLBP_M = mapping.table(CLBP_M+1);
        CLBP_S = reshape(CLBP_S,sizarray);
        CLBP_M = reshape(CLBP_M,sizarray);
    end

    result=CLBP_S;
    if (numBlk>=1)
        if size(numBlk,2)==1
            k1=numBlk;
            k2=k1;
        else
            k1=numBlk(1);
            k2=numBlk(2);
        end


        [ysize xsize]=size(result);
        temp2=[];
        wR=floor(xsize/k1);
        hR=floor(ysize/k2);
        for i=1:k2
            y_start=(i-1)*hR+1;
            y_end=i*hR;
            if i==k2
                y_end=ysize;
            end
            for j=1:k1
                x_start=(j-1)*wR+1;
                x_end=j*wR;
                if j==k1
                    x_end=xsize;
                end

                temp(:,:)=result(y_start:y_end,x_start:x_end);
                temp1=hist(temp(:),0:(bins-1));
                temp1=temp1/sum(temp1);

                %  temp1=normal_hist(temp1);
                temp2=[temp2 temp1];
                clear temp;
                clear temp1;
            end
        end

        result=temp2;
        clear temp;
        clear temp2;
    end
    S_hist = S_hist+result;


    result=CLBP_M;
    if (numBlk>=1)
        if size(numBlk,2)==1
            k1=numBlk;
            k2=k1;
        else
            k1=numBlk(1);
            k2=numBlk(2);
        end

        [ysize xsize]=size(result);
        temp2=[];
        wR=floor(xsize/k1);
        hR=floor(ysize/k2);
        for i=1:k2
            y_start=(i-1)*hR+1;
            y_end=i*hR;
            if i==k2
                y_end=ysize;
            end
            for j=1:k1
                x_start=(j-1)*wR+1;
                x_end=j*wR;
                if j==k1
                    x_end=xsize;
                end

                temp(:,:)=result(y_start:y_end,x_start:x_end);
                temp1=hist(temp(:),0:(bins-1));
                temp1=temp1/sum(temp1);

                %  temp1=normal_hist(temp1);
                temp2=[temp2 temp1];
                clear temp;
                clear temp1;
            end
        end

        result=temp2;
        clear temp;
        clear temp2;
    end
    M_hist = M_hist+result;

end

if (strcmp(mode,'nh'))
    S_hist=S_hist/sum(S_hist);
    M_hist=M_hist/sum(M_hist);
end

end