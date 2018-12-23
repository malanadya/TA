clear all;
clc;
addpath([cd '/utilities']);

%----------------------------------paramter name in the paper--
minWaveLength       =  4;          %lambda_min
sigmaOnf            =  0.64;       %miu
mult                =  1.7;        %delta_ratio
region_num          =  8;
nscale              =  3;          %the number of scales
bin_num_a           =  512;
total               =  1024;
phase_bin           =  4;
Eigen_NUM           =  [400];      %PCA dimension
Axes_NUM            =  [200];      %BFLD dimension
orientWrap          =  1;
method              = 'cos';
nameDatabase        =  'dup1_paper';
folder_tr           =  'dup1_training';
folder_ta           =  'dup1_target';
folder_qu           =  'dup1_query';
bh_n                =  5;         %Mb
bw_n                =  5;         %Mb
sh_n                =  2;         %Mr
sw_n                =  2;         %Mr
neigh               =  8;
radius              =  4;
NumTraining         =  1002;
NumQuery            =  722;
NumTarget           =  1196;

MAPPING             =  getmapping(neigh,'u2');
%-------process train--------------------------------------------------
dat_path     = [cd '/data'];
load([dat_path '/FERET_training_nohistmask']); 

for i = 1: NumTraining
    fprintf(['processed...' num2str(i/NumTraining*100) '%%...\n']);
    Tem_img     =     training_dat(:,i);  Tem_img = reshape(Tem_img,[150 130]);
    [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(Tem_img, ...
            nscale, minWaveLength, mult, sigmaOnf, orientWrap);
        
    for v=1:nscale
        Tem_img=uint16((psi1{v}-min(psi1{v}(:)))./(max(psi1{v}(:))-min(psi1{v}(:))).*360);
        LBPHIST=lxp_phase(Tem_img,radius,neigh,0,'i');
        matrix2=zeros(size(h1f1{v}));matrix3=zeros(size(h2f1{v}));
        matrix2(h1f1{v}>0)=0;matrix2(h1f1{v}<=0)=1;matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
        matrix3(h2f1{v}>0)=0;matrix3(h2f1{v}<=0)=1;matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
        N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);
        N_LBPHIST=uint16(N_LBPHIST);
        HIST(v).im = N_LBPHIST;
    end
     filename=[folder_tr '/H_FERET_Training' num2str(i)];save(filename,'HIST');
end

for sub_ri = 1: bh_n*bw_n
    Train_theta=[];
    fprintf(['processed subregion...' num2str(sub_ri) '...\n']);
    for i = 1: NumTraining
        filename=[folder_tr '/H_FERET_Training' num2str(i)];load(filename);
        Tem_thera = [];
        for v=1:nscale
            N_LBPHIST = HIST(v).im;
            height  =  size(N_LBPHIST,1);
            width   =  size(N_LBPHIST,2);
            [br_h_index,br_w_index] = construct_region_index(sub_ri,bh_n,bw_n,sh_n,...
                sw_n,height,width);
            [Hist_A]=Count_Region_hist(N_LBPHIST(br_h_index,br_w_index),...
                sw_n,sh_n,bin_num_a,total);
            Tem_thera = [Tem_thera Hist_A];
        end
        Train_theta = [Train_theta Tem_thera(:)];
    end
    filename=[folder_tr '/D_FERET_Training_' num2str(sub_ri)];save(filename,'Train_theta');
    clear Train_theta;
end

%-------process target--------------------------------------------------
dat_path     = [cd '/data'];
load([dat_path '/Fa_dat_nohistmask']); 
target_label  =  fa_label;  %130*150
Target_dat    =  fa_dat;

for i = 1: NumTarget
    fprintf(['processed...' num2str(i/NumTarget*100) '%%...\n']);
    Tem_img       = Target_dat(:,i);  Tem_img = reshape(Tem_img,[150 130]);
    [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(Tem_img, ...
            nscale, minWaveLength, mult, sigmaOnf, orientWrap);
        
    for v=1:nscale
        Tem_img=uint16((psi1{v}-min(psi1{v}(:)))./(max(psi1{v}(:))-min(psi1{v}(:))).*360);
        LBPHIST=lxp_phase(Tem_img,radius,neigh,0,'i');
        matrix2=zeros(size(h1f1{v}));matrix3=zeros(size(h2f1{v}));
        matrix2(h1f1{v}>0)=0;matrix2(h1f1{v}<=0)=1;matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
        matrix3(h2f1{v}>0)=0;matrix3(h2f1{v}<=0)=1;matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
        N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);
        N_LBPHIST=uint16(N_LBPHIST);
        HIST(v).im = N_LBPHIST;
    end
     filename=[folder_ta '/H_FERET_Target' num2str(i)];save(filename,'HIST');
end

for sub_ri = 1: bh_n*bw_n
    Target_theta=[];
    fprintf(['processed subregion...' num2str(sub_ri) '...\n']);
    for i = 1: NumTarget
        filename=[folder_ta '/H_FERET_Target' num2str(i)];load(filename);
        Tem_thera = [];
        for v=1:nscale
            N_LBPHIST = HIST(v).im;
            height  =  size(N_LBPHIST,1);
            width   =  size(N_LBPHIST,2);
            [br_h_index,br_w_index] = construct_region_index(sub_ri,bh_n,bw_n,...
                sh_n,sw_n,height,width);
            [Hist_A]=Count_Region_hist(N_LBPHIST(br_h_index,br_w_index),...
                sw_n,sh_n,bin_num_a,total);
            Tem_thera = [Tem_thera Hist_A];
        end
        Target_theta = [Target_theta Tem_thera(:)];
    end
    filename=[folder_ta '/D_FERET_Target_' num2str(sub_ri)];save(filename,'Target_theta');
    clear Target_theta;
end

%-------process query--------------------------------------------------
load([dat_path '/Dup1_dat_nohistmask']);
Query_dat   = dup1_dat;
query_label = dup1_label;

for i = 1: NumQuery
    fprintf(['processed...' num2str(i/NumQuery*100) '%%...\n']);
    Tem_img       =  Query_dat(:,i);  Tem_img = reshape(Tem_img,[150 130]);
    [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(Tem_img, ...
            nscale, minWaveLength, mult, sigmaOnf, orientWrap);
        
    for v=1:nscale
        Tem_img=uint16((psi1{v}-min(psi1{v}(:)))./(max(psi1{v}(:))-min(psi1{v}(:))).*360);
        LBPHIST=lxp_phase(Tem_img,radius,neigh,0,'i');
        matrix2=zeros(size(h1f1{v}));matrix3=zeros(size(h2f1{v}));
        matrix2(h1f1{v}>0)=0;matrix2(h1f1{v}<=0)=1;matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
        matrix3(h2f1{v}>0)=0;matrix3(h2f1{v}<=0)=1;matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
        N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);
        N_LBPHIST=uint16(N_LBPHIST);
        HIST(v).im = N_LBPHIST;
    end
     filename=[folder_qu '/H_FERET_Query' num2str(i)];save(filename,'HIST');
end

for sub_ri = 1: bh_n*bw_n
    Query_theta=[];
    fprintf(['processed subregion...' num2str(sub_ri) '...\n']);
    for i = 1: NumQuery
        filename=[folder_qu '/H_FERET_Query' num2str(i)];load(filename);
        Tem_thera = [];
        for v=1:nscale
            N_LBPHIST = HIST(v).im;
            height  =  size(N_LBPHIST,1);
            width   =  size(N_LBPHIST,2);
            [br_h_index,br_w_index] = construct_region_index(sub_ri,bh_n,bw_n,...
                sh_n,sw_n,height,width);
            [Hist_A]=Count_Region_hist(N_LBPHIST(br_h_index,br_w_index),...
                sw_n,sh_n,bin_num_a,total);
            Tem_thera = [Tem_thera Hist_A];
        end
        Query_theta = [Query_theta Tem_thera(:)];
    end
    filename=[folder_qu '/D_FERET_Query_' num2str(sub_ri)];save(filename,'Query_theta');
    clear Query_theta;
end

%--------------learn FLD ---------------------------------
numQ   =  NumQuery;
numT   =  NumTarget;
for eig_i = 1:size(Eigen_NUM,2)
    for axe_i = 1: size(Axes_NUM,2)
   
    [fisher_d]=LearnFLD_NEW(Eigen_NUM(eig_i),Axes_NUM(axe_i),bh_n*bw_n,training_label,folder_tr);
    [reco_ratio,reco_ratio_O] = compute_mbp_dup1_NEW(numQ,numT,bh_n*bw_n,method,folder_tr,folder_ta,...
        folder_qu,target_label,query_label,nameDatabase); 
    
     fid = fopen([cd '\result\demo_FERET_MBP_phase_final_' nameDatabase '.txt'],'a');
     fprintf(fid,'---------------------------------------------------\n');
     fprintf(fid,'%s%f%s%f%s%-8f%s%-8f\n','minWaveLength = ', minWaveLength,'   sigmaOnf=', sigmaOnf,...
        '   mult=', mult, '  nscale = ', nscale);
     fprintf(fid,'%s%f%s%f%s%-8f%s%-8f\n','bh_n = ', bh_n,'   bw_n=', bw_n,...
        '   sh_n=', sh_n, '  sw_n = ', sw_n);
     fprintf(fid,'%s%f%s%f%s%f%s%f%s%f\n','nscale= ',nscale,'   bin_num_a= ',bin_num_a,...
         '   total = ',total, ' pahse_bin = ',phase_bin,' radius = ',radius);
     fprintf(fid,'%s%f%s%f\n','eigen_num= ',Eigen_NUM(eig_i),'   fisher_dim= ',Axes_NUM(axe_i));
     fprintf(fid,'%s%f%s%s%s%-8f%s%-8f\n','fisher_d = ', fisher_d,'   method=', method,...
        '   reco_rate=', reco_ratio, '  reco_ratiio_O = ', reco_ratio_O);
     fclose(fid);
    
    end
end