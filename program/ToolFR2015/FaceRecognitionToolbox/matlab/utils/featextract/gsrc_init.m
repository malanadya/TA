

im_w = 19;
im_h = 22;

par.ds_w       =    im_w/6.3;       % the downsample image's width in Gabor
par.ds_h       =    im_h/6.3;       % the downsample image's heigth in Gabor
par.ke_w       =    31;             % Gabor kernel's width
par.ke_h       =    31;             % Gabor kernel's heigth
par.raT        =    0.9;            % Gabor kernel's energy preseving ratio
par.Kmax       =    pi/2;           % Gabor kernel's para, default(pi/2)
par.f          =    sqrt(2);        % Gabor kernel's para, default(sqrt(2))
par.sigma      =    pi;             % Gabor kernel's para, default(pi or 1.5pi)
par.Gabor_num  =    40;             % Gabor kernel's number, default (5 scales and 8 orientations)

par.lambda_l   =    0.0005;         % parameter of l1_ls in learning
par.lambda_t   =    0.0005;         % parameter of l1_ls in testing
par.dim        =    100;            % the occlusion column dimension; (200 for yaleb) (100 for ar)
par.dl_nIter   =    15;             % the maximal iteration number in occlusion dictionary learning

if mod(par.ke_w,2)~=1 | mod(par.ke_h,2)~=1
    error('The width and height of Gabor kernel should be odd number');
end

[ GaborReal, GaborImg ]  =   MakeAllGaborKernal( par.ke_h, par.ke_w ,par.Gabor_num,par.Kmax, par.f, par.sigma);

radius_w       =    floor(par.ke_w/2);
radius_h       =    floor(par.ke_h/2);
center_w       =    radius_w+1;
center_h       =    radius_h+1;
ker_ener       =    [];

% according the par.raT to select a suitable and accurate size of kernel window
for step  =  1: (radius_w+radius_h)/2
    ratio          =    0;
for i  =  1 :40
    temp_r1 = sum(sum(abs(GaborReal(center_h-radius_h+step:center_h+radius_h-step,center_w-radius_w+step:center_w+radius_w-step,i))));
    temp_r2 = sum(sum(abs(GaborReal(:,:,i))));
    temp_i1 = sum(sum(abs(GaborImg(center_h-radius_h+step:center_h+radius_h-step,center_w-radius_w+step:center_w+radius_w-step,i))));
    temp_i2 = sum(sum(abs(GaborImg(:,:,i))));
    ratio   = ratio + temp_r1/temp_r2/80 + temp_i1/temp_i2/80;
end
   ker_ener = [ker_ener ratio];
   if ratio < par.raT
      step = step - 1;
      break;
   end
end

load('Occlu_Lear_Dict200_22_19');
%load('Occlu_Lear_Dict200_64_64');
Ae = D_Oclu;