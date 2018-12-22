function [ MFS ] = CombineTmpl( image )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exact 2 type of features from input images including
% energy and counting of orientation.
% 
% input:
%   image: input image for feature extraction.
%   
% output:
%   MFS: Multi-fractal Spectrum feature to represent image
%
% 
%   This is the basic code of orientation template approach.
%   It's performance can be improved by combining different kinds of input
%   filter as show by comment.
%
% Written by Huang Sibin
% Update in 2012.1.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameter for adjustment of feature extraction
nLevel=5;   % number of windows size for orientation calculation
nEst = 4;   % number of estimation points by Least Square

%% the image parameters
im=single(image);

%% Using [1..256] to denote the intensity profile of the image
GRAY_BOUND =[1, 256];
im = GRAY_BOUND(1)+ (GRAY_BOUND(2)-GRAY_BOUND(1)) * ...
    (im - min(im(:)))/(max(im(:))-min(im(:)));

%% compute the gradient of the image
x_mask=0.5*[0,-1,0;0,0,0,;0,1,0];
y_mask=0.5*[0,0,0;-1,0,1,;0,0,0];
G_x = conv2(im,x_mask,'same');
G_y = conv2(im,y_mask,'same');

%%compute the orient and the magnitude of the gradient
G_mag = sqrt( G_x.^2 + G_y.^2 );
G_orient = atan2( G_y, G_x );
G_orient(G_orient == pi) = -pi;

%% formulation of oriental templates
orient_bin_num=8;   % number of orientation bin 
orient_bin_step = 2*pi/orient_bin_num; % range of bin step
for n = 1:nLevel
    mask=ones(2*n+1,2*n+1);
    norm_map = conv2(single(G_mag),mask,'same');
    for i = 1:orient_bin_num
        map = G_orient >= -pi+(i-1)*orient_bin_step & G_orient < -pi+i*orient_bin_step;
        mag_map = G_mag.*map;
        bin{n,i} = conv2(single(map),mask,'same')/ ((2*n+1)^2);  %normalized counting templates
        mag_bin{n,i} = conv2(single(mag_map),mask,'same') ./ norm_map; % normalized energy templates
    end        
end

%% compute the orient templet MFS 29 kinds of templet
bin2dec_mask=[1,2,4,8,16,32,64,128]'; % bit operator for template classification

% Generate the pre-defined templates by bit operation
templet=GenTemplate(1); % Generation of templates
tempLen = length(templet);
%% Calculate MFS by boxcounting and least square method
for k = 1:nLevel 
    %%% Engery templates to form MFS
    temp_bin=[];
    for m = 1:orient_bin_num
        temp_bin(:,:,m) = mag_bin{k,m};
    end
    [tmp_row,tmp_col]=size(mag_bin{k,1});
    descriptor = reshape(temp_bin,[tmp_row*tmp_col,orient_bin_num]);
    bitMap = descriptor >= 0.122 & descriptor < 0.5;
    templet_num = bitMap*bin2dec_mask;
    %%%% templates classification
    for p = 1:tempLen %number of templet
        bw_pos = ismember(templet_num,templet{p});
        bw_map = single(reshape(bw_pos,[tmp_row,tmp_col]));
        if bw_map == 0
            magMFS((k-1)*tempLen + p) = 0;
        else
            %% Computation of fractal dimension
            magMFS((k-1)*tempLen + p) = bw2MFS(bw_map,nEst); 
        end
    end
    %%%% clear memory
    clear temp_bin;
    %%% counting template to form MFS
    temp_bin=[];
    for m = 1:orient_bin_num
        temp_bin(:,:,m) = bin{k,m};
    end
    [tmp_row,tmp_col]=size(bin{k,1});
    descriptor = reshape(temp_bin,[tmp_row*tmp_col,orient_bin_num]);
    bitMap = descriptor >= 0.11;
    templet_num = bitMap*bin2dec_mask;
    %%%% templates classification
    for p = 1:tempLen %number of templet
        bw_pos = ismember(templet_num,templet{p});
        bw_map = single(reshape(bw_pos,[tmp_row,tmp_col]));
        if bw_map == 0
            oriMFS((k-1)*tempLen + p) = 0;
        else
            %% Computation of fractal dimension
            oriMFS((k-1)*tempLen + p) = bw2MFS(bw_map,nEst);
        end
    end
    %%%  clear memory
    clear temp_bin;
end
%% Combine energy and counting MFS together.
MFS = [magMFS,oriMFS];
