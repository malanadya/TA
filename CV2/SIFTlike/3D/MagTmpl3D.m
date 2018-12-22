function [ MFS ] = MagTmpl3D( sequence )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exact counting templates features from input image sequence
% 
% input:
%   sequence: input image sequence for feature extraction.
%   
% output:
%   MFS: Multi-fractal Spectrum feature to represent image sequence
%
% Written by Huang Sibin
% Update in 2012.1.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameter for adjustment of feature extraction
nLevel=5; % number of windows size for orientation calculation
nEst = 3; % number of estimation points by Least Square
nZero =5; % eliminate small numbers

%% the image parameters
seq=double(sequence);

%% Using [1..256] to denote the intensity profile of the image
GRAY_BOUND =[1, 256];
seq = GRAY_BOUND(1)+ (GRAY_BOUND(2)-GRAY_BOUND(1)) * ...
    (seq - min(seq(:)))/(max(seq(:))-min(seq(:)));
[row,col,nframe] = size(seq); 

%% compute the gradient of the image
x_mask=zeros(2,2,2);
y_mask=zeros(2,2,2);
z_mask=zeros(2,2,2);
x_mask(:,:,1)=[0.5,0;0,-0.5];
y_mask(:,:,1)=[0,-0.5;0.5,0];
z_mask(:,:,1)=[0.5,0;0,0];
z_mask(:,:,2)=[-0.5,0;0,0];
G_x = convn(seq,x_mask,'same');
G_y = convn(seq,y_mask,'same');
G_z = convn(seq,z_mask,'same');

%% compute 2 orientations of the gradient by energy
G_mag_2D = sqrt( G_x.^2 + G_y.^2);
G_mag_3D = sqrt( G_x.^2 + G_y.^2 + G_z.^2);
G_theta = atan2( G_y, G_x );
G_theta(G_theta == pi) = -pi;
G_phi = atan(G_z ./ G_mag_2D);
G_phi(G_mag_2D==0)=pi;
G_phi(G_phi == pi) = -pi;
G_phi(isnan(G_phi)) = -pi;

%% compute the orient templet MFS 29 kinds of templet
bin2dec_mask=[1,2,4,8,16,32,64,128]';

% Generate the pre-defined templates by bit operation
templet = GenTemplate(1); % Generation of templates
tempLen = length(templet);

%% Calculate MFS by boxcounting and least square method
orient_bin_num=8;
orient_bin_step = 2*pi/orient_bin_num;
for n = 1:nLevel
    for f=1:nframe
        temp_mag = G_mag_3D(:,:,f);
        mask=ones(2*n+1,2*n+1);
        norm_map = conv2(single(temp_mag),mask,'same');
        for i = 1:orient_bin_num
            map = G_theta(:,:,f) >= -pi+(i-1)*orient_bin_step & G_theta(:,:,f) < -pi+i*orient_bin_step;
            mag_map = temp_mag.*map;
            mag_bin_up{f,i} = conv2(single(mag_map),mask,'same') ./ norm_map;
            
            map = G_phi(:,:,f) >= -pi+(i-1)*orient_bin_step & G_phi(:,:,f) < -pi+i*orient_bin_step;
            mag_map = temp_mag.*map;
            mag_bin_down{f,i} = conv2(single(mag_map),mask,'same') ./ norm_map;
        end
    end
   
    for f=1:nframe
        %%% Mag to MFS
        temp_mag_up=zeros(row,col,orient_bin_num);
        temp_mag_down=zeros(row,col,orient_bin_num);
        for m = 1:orient_bin_num
            temp_mag_up(:,:,m) = mag_bin_up{f,m};
            temp_mag_down(:,:,m) = mag_bin_down{f,m};
        end
        [tmp_row,tmp_col]=size(mag_bin_up{1,1});
        descriptor_up = reshape(temp_mag_up,[tmp_row*tmp_col,orient_bin_num]);
        descriptor_down = reshape(temp_mag_down,[tmp_row*tmp_col,orient_bin_num]);
        bitMap_up = descriptor_up >= 0.1;% 0.12 & descriptor_up < 0.5;
        bitMap_down = descriptor_down >= 0.1;% 0.12 & descriptor_up < 0.5;
        templet_num_up = bitMap_up*bin2dec_mask;
        templet_num_down = bitMap_down*bin2dec_mask;
        for p = 1:tempLen %number of templet
            bw_pos = ismember(templet_num_up,templet{p});
            bw_map = single(reshape(bw_pos,[tmp_row,tmp_col]));
            seq_frame_bw_up{f,p}=bw_map;
            
            bw_pos = ismember(templet_num_down,templet{p});
            bw_map = single(reshape(bw_pos,[tmp_row,tmp_col]));
            seq_frame_bw_down{f,p}=bw_map;
        end
    end
    clear descriptor_up descriptor_down bitMap_up bitMap_down temp_mag_up temp_mag_down
    for p=1:tempLen
        temp_seq_bw_up=zeros(row,col,nframe);
        temp_seq_bw_down=zeros(row,col,nframe);
        for f=1:nframe
            temp_seq_bw_up(:,:,f) = seq_frame_bw_up{f,p};
            temp_seq_bw_down(:,:,f) = seq_frame_bw_down{f,p};
        end
        
        if sum(sum(temp_seq_bw_up ~= 0)) < nZero
            magMFS_up((n-1)*tempLen + p) = 0;
        else
            magMFS_up((n-1)*tempLen + p) = bw2MFS3D(temp_seq_bw_up,nEst);
        end
        
        if sum(sum(temp_seq_bw_down ~= 0)) < nZero
            magMFS_down((n-1)*tempLen + p) = 0;
        else
            magMFS_down((n-1)*tempLen + p) = bw2MFS3D(temp_seq_bw_down,nEst);
        end
    end
    clear temp_seq_bw_up temp_seq_bw_down
end
MFS=[magMFS_up,magMFS_down];
