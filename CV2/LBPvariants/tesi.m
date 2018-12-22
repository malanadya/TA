

function A = tesi(varargin) %i,THRESHOLD,neighbors,luogo,param1,param2,beta,mapping,mode

%check input arguments
error(nargchk(1,9,nargin));
image=varargin{1};
d_image=double(image);

if nargin==1
    THRESHOLD=[];
    spoints=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
    mapping=0;
    mode='h';
end

if (nargin == 2) && (length(varargin{2}) == 1)
    error('Input arguments');
end

if (nargin > 4)
    THRESHOLD=varargin{2};
    LUOGO=varargin{4};
    neighbors=varargin{3};
    if( (strcmpi('el',LUOGO)) && (mod(neighbors,4) ~= 2) ) %just to have a uniform distribuition of neighbors
        error('Hyperbole requires mod(neighbors,4)==2 neighbors');
    end
    PARAM1=varargin{5};
    if ((strcmpi('el',LUOGO) || strcmpi('sp',LUOGO)) && (nargin<6))
        error('2 geometric parameters required');
    end

    if (nargin>5)
        PARAM2=varargin{6};
    end


    if (~strcmpi('el',LUOGO) || ~strcmpi('sp',LUOGO))
        if (nargin>=6)
            beta=deg2rad(varargin{7});
        else
            beta=0;
        end
    else
        if (nargin>=7)
            beta=deg2rad(varargin{7});
        else
            beta=0;
        end
    end
    
    PARAM1=varargin{5};
    PARAM2=varargin{6};
    beta=deg2rad(varargin{7});
    
    %Call function to create spoints
    spoints=intorno(LUOGO,neighbors,PARAM1,PARAM2);
    %matrix used for rotation
    Rotate=[cos(beta),sin(beta); -sin(beta),cos(beta)];
    spoints=spoints*Rotate;

    if(nargin >= 5)
        mapping=varargin{8};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end

    if(nargin >= 6)
        mode=varargin{9};
    else
        mode='h';
    end
end

if (nargin > 2) && (length(varargin{3}) > 1)
    spoints=varargin{3};
    THRESHOLD=varargin{2};

    if(nargin >= 4)
        beta=deg2rad(varargin{4});
    else
        beta=0;
    end
    Rotate=[cos(beta),sin(beta); -sin(beta),cos(beta)];
    spoints=spoints*Rotate;

    if(nargin >= 5)
        mapping=varargin{8};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end

    if(nargin >= 6)
        mode=varargin{9};
    else
        mode='h';
    end
end

% Determine the dimensions of the input image.
[ysize xsize] = size(image);

neighbors=size(spoints,1);

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
C = image(origy:origy+dy,origx:origx+dx);%ritaglia l'immagine originale sulla quale estrarre istogrammi
d_C = double(C);

bins = 2^neighbors;%The LBP operator produces 2P different output values,
% corresponding to the 2P different binary patterns that can be
% formed by the P pixels in the neighbor set.

% Initialize the result matrix with zeros and check how many output vectors
% are required
result1=zeros(dy+1,dx+1);
if (isempty(THRESHOLD))
    result2=[];
    result3=[];
    result4=[];
else
    result2=zeros(dy+1,dx+1);
    if(length(THRESHOLD)==2)
        result3=zeros(dy+1,dx+1);
        result4=zeros(dy+1,dx+1);
    end

end

for i = 1:neighbors
    y = spoints(i,1)+origy;
    x = spoints(i,2)+origx;
    % Calculate floors, ceils and rounds for the x and y.
    fy = floor(y); cy = ceil(y); ry = round(y);
    fx = floor(x); cx = ceil(x); rx = round(x);
    % Check if interpolation is needed.
    if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
        % Interpolation is not needed, use original datatypes
        N = image(ry:ry+dy,rx:rx+dx);
        if (isempty(THRESHOLD))
            D = N >= C;
        else
            D=zeros(size(N,1),size(N,2));
            if (length(THRESHOLD)==1)
                D(find(N >= (C+THRESHOLD)))=+1;
                D(find(N <= (C-THRESHOLD)))=-1;
                D1=D;D1(find(D==-1))=0;
                D2=D;D2(find(D==1))=0;D2=D2*-1;
            else
                D(find(N >= (C+THRESHOLD(1))))=1;
                D(find(N >= (C+THRESHOLD(2))))=2;
                D(find( N <= (C-THRESHOLD(1)) ))=-1;
                D(find(N <= (C-THRESHOLD(2))))=-2;
                D1=D;D1(find(D==-1))=0;D1(find(D==-2))=0;D1(find(D==2))=0;
                D2=D;D2(find(D==1))=0;D2(find(D==-2))=0;D2(find(D==2))=0;D2=D2*-1;
                D3=D;D3(find(D==-2))=0;D3(find(D==1))=0;D3(find(D==-1))=0;D3(find(D==2))=1;
                D4=D;D4(find(D==2))=0;D4(find(D==1))=0;D4(find(D==-1))=0;D4(find(D==-2))=1;            
            end
        end
    else
        % Interpolation needed, use double type images
        ty = y - fy;
        tx = x - fx;

        % Calculate the interpolation weights.
        w1 = (1 - tx) * (1 - ty);
        w2 =      tx  * (1 - ty);
        w3 = (1 - tx) *      ty ;
        w4 =      tx  *      ty ;
        % Compute interpolated pixel values
        N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
            w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);
        if(isempty(THRESHOLD))
            D = N >= d_C;
        else
            D=zeros(size(N,1),size(N,2));
            if (length(THRESHOLD)==1)
                D(find(N >= (d_C+THRESHOLD)))=+1;
                D(find(N <= (d_C-THRESHOLD)))=-1;
                D1=D;D1(find(D==-1))=0;
                D2=D;D2(find(D==1))=0;D2=D2*-1;
            else
                D(find(N >= (C+THRESHOLD(1))))=1;
                D(find(N >= (C+THRESHOLD(2))))=2;
                D(find( N <= (C-THRESHOLD(1)) ))=-1;
                D(find(N <= (C-THRESHOLD(2))))=-2;
                D1=D;D1(find(D==-1))=0;D1(find(D==-2))=0;D1(find(D==2))=0;
                D2=D;D2(find(D==1))=0;D2(find(D==-2))=0;D2(find(D==2))=0;D2=D2*-1;
                D3=D;D3(find(D==-2))=0;D3(find(D==1))=0;D3(find(D==-1))=0;D3(find(D==2))=1;
                D4=D;D4(find(D==2))=0;D4(find(D==1))=0;D4(find(D==-1))=0;D4(find(D==-2))=1;
            end
        end
    end
    % Update the result matrix.
    v = 2^(i-1);

    if(isempty(THRESHOLD))
        result1 = result1 + v*D;
    else
        result1 = result1 + v*D1;
        result2 = result2 + v*D2;
        if(length(THRESHOLD)==2)
            result3 = result3 + v*D3;
            result4 = result4 + v*D4;
        end
    end

end

%Apply mapping if it is defined, il mapping serve per la rotazione:
% The LBPP;R operator produces 2P different output values,
% corresponding to the 2P different binary patterns that can be
% formed by the P pixels in the neighbor set. When the image
% is rotated, the gray values gp will correspondingly move
% along the perimeter of the circle around g0. Since g0 is
% always assigned to be the gray value of element (0;R) to the
% right of gc rotating a particular binary pattern naturally
% results in a different LBPP;R value. This does not apply to
% patterns comprising of only 0s (or 1s) which remain
% constant at all rotation angles.
if isstruct(mapping)
    bins = mapping.num;
    for i = 1:size(result1,1)
        for j = 1:size(result1,2)
            result1(i,j) = mapping.table(result1(i,j)+1);
            if(~isempty(THRESHOLD))
                result2(i,j) = mapping.table(result2(i,j)+1);
                if(length(THRESHOLD)==2)
                    result3(i,j) = mapping.table(result3(i,j)+1);
                    result4(i,j) = mapping.table(result4(i,j)+1);
                end
            end
        end
    end
end


if (strcmp(mode,'h') || strcmp(mode,'hist') || strcmp(mode,'nh'))
    % Return with LBP histogram if mode equals 'hist'.
    result1=hist(result1(:),0:(bins-1));
    if (strcmp(mode,'nh'))
        result1=result1/sum(result1);
    end
    if(~isempty(THRESHOLD))
        result2=hist(result2(:),0:(bins-1));
        if (strcmp(mode,'nh'))
            result2=result2/sum(result2);
        end
        if(length(THRESHOLD)==2)
            result3=hist(result3(:),0:(bins-1));
            if (strcmp(mode,'nh'))
                result3=result3/sum(result3);
            end
            result4=hist(result4(:),0:(bins-1));
            if (strcmp(mode,'nh'))
                result4=result4/sum(result4);
            end
        end
    end
end

if ( isempty(THRESHOLD) )
    A=result1;
else
    if ( length(THRESHOLD)==1)
        A=[result1 result2];
    else
        A=[result1 result2 result3 result4];
    end
end
end






