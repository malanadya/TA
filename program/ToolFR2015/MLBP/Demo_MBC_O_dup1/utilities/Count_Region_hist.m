function [Hist_A]=Count_Region_hist(img_A,region_num_w,region_num_h,bin_num_a,total)
% this function construct the histgram of regions
% region_num*region_num

% if (mod(size(img_A,1),region_num)~=0)|(mod(size(img_A,2),region_num)~=0)
%     fprintf('The image can not be divided by "region_num"');
% end

w_step=floor(size(img_A,2)/region_num_w);
h_step=floor(size(img_A,1)/region_num_h);

region_w_index=[];
region_h_index=[];

for w_i=1:region_num_w
    for h_i=1:region_num_h
       region_w_index=[region_w_index;[(w_i-1)*w_step+1:w_i*w_step]];
       region_h_index=[region_h_index;[(h_i-1)*h_step+1:h_i*h_step]];
    end
end

% orientWrap is 0 theta will be returned in the range -pi .. pi and psi will
% be returned in the range -pi/2 .. pi/2.
% suppose A1's range is [0 255];

%global normlization
% img_A=255.*(img_A-min(img_A(:)))./(max(img_A(:))-min(img_A(:)));

step_bin_a=total/bin_num_a;
for R_num=1:region_num_w*region_num_h
    Hist_A(:,R_num)=zeros(bin_num_a,1);
    region=img_A(region_h_index(R_num,:),region_w_index(R_num,:));

    for i=1:bin_num_a
        range_l=(i-1)*step_bin_a;range_h=step_bin_a*i;
        tem_index=find(region>=range_l&region<range_h);
        Hist_A(i,R_num)=(length(tem_index));
    end
end
Hist_A = uint16(Hist_A);