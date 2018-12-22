function sift_arr = gridHOG(I, grid_x, grid_y, patch_size, sigma_edge)

% parameters
num_angles = 8;
num_bins = 4;
num_samples = num_bins * num_bins;
alpha = 9;

[hgt wid] = size(I);
num_patches = numel(grid_x);

sift_arr = zeros(num_patches, num_samples * num_angles);

% make default grid of samples (centered at zero, width 2)
interval = 2/num_bins:2/num_bins:2;
interval = interval - (1/num_bins + 1);
[sample_x sample_y] = meshgrid(interval, interval);
sample_x = reshape(sample_x, [1 num_samples]);
sample_y = reshape(sample_y, [1 num_samples]);



% for all patches
for i=1:num_patches
    r = patch_size/2;
    cx = grid_x(i) + r - 0.5;
    cy = grid_y(i) + r - 0.5;

    % find coordinates of sample points (bin centers)
    sample_x_t = sample_x * r + cx;
    sample_y_t = sample_y * r + cy;
    sample_res = sample_y_t(2) - sample_y_t(1);
    
    % find window of pixels that contributes to this descriptor
    x_lo = grid_x(i);
    x_hi = grid_x(i) + patch_size - 1;
    y_lo = grid_y(i);
    y_hi = grid_y(i) + patch_size - 1;
    
         
    % make sift descriptor
    
    
    sift_arr(i,:) = reshape(curr_sift, [1 num_samples * num_angles]);    
        

end

