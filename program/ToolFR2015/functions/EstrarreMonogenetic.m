
function Query_theta=EstrarreMonogenetic(MB, VOLTO,nscale, minWaveLength, mult, sigmaOnf,radius,neigh,bh_n,bw_n,sh_n,sw_n,bin_num_a,total)

if MB==1

    %MBC_A
    [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(VOLTO, ...
        nscale, minWaveLength, mult, sigmaOnf, 0);
    for v=1:nscale
        Tem_img=uint8((A1{v}-min(A1{v}(:)))./(max(A1{v}(:))-min(A1{v}(:))).*255);
        LBPHIST=lbpM(Tem_img,radius,neigh,0,'i');
        matrix2=zeros(size(h1f1{v}));matrix3=zeros(size(h2f1{v}));
        matrix2(h1f1{v}>0)=0;matrix2(h1f1{v}<=0)=1;matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
        matrix3(h2f1{v}>0)=0;matrix3(h2f1{v}<=0)=1;matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
        N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);%max=256;
        N_LBPHIST=uint16(N_LBPHIST);
        HIST(v).im = N_LBPHIST;
    end

elseif MB==2

    %MBC_O
    [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(VOLTO, ...
        nscale, minWaveLength, mult, sigmaOnf, 0);
    for v=1:nscale
        Tem_img=uint16((theta1{v}-min(theta1{v}(:)))./(max(theta1{v}(:))-min(theta1{v}(:))).*360);
        LBPHIST=lxp_phase(Tem_img,radius,neigh,0,'i');
        matrix2=zeros(size(h1f1{v}));matrix3=zeros(size(h2f1{v}));
        matrix2(h1f1{v}>0)=0;matrix2(h1f1{v}<=0)=1;matrix2=matrix2(radius+1:end-radius,radius+1:end-radius);
        matrix3(h2f1{v}>0)=0;matrix3(h2f1{v}<=0)=1;matrix3=matrix3(radius+1:end-radius,radius+1:end-radius);
        N_LBPHIST=matrix2*512+matrix3*256+double(LBPHIST);%max=256;
        %         N_LBPHIST=double(LBPHIST);%max=256;
        N_LBPHIST=uint16(N_LBPHIST);
        HIST(v).im = N_LBPHIST;
    end

elseif MB==3

    %MBC_P
    [f1, h1f1, h2f1, A1,theta1, psi1] = monofilt(VOLTO, ...
        nscale, minWaveLength, mult, sigmaOnf, 1);

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
end

Query_theta=[];
for sub_ri = 1: bh_n*bw_n
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
    Query_theta = [Query_theta; Tem_thera(:)];
end
Query_theta=single(Query_theta');
