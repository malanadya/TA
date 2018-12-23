function I1=PrePimageTool(I1,metodo)

%It works with gray level images
if size(I1,3)>1
    I1=rgb2gray(I1);
end
if metodo==1
    I1=LOG_DCT_1(I1);
elseif metodo==2
    I1= OLHE_kbyk( I1 , 3 );
elseif metodo==3
    I1=multi_scale_retinex(I1,[7 15 21]);
elseif metodo==4
    I1 = adaptive_single_scale_retinex(I1,15);
elseif metodo==5
    I1 = isotropic_smoothing(I1);
elseif metodo==6
    I1 = anisotropic_smoothing(I1);
elseif metodo==7
    I1 = tantriggs(I1);
elseif metodo==8
    I1 = dog(log(single(I1)+1));
elseif metodo==9
    I1 = gradientfaces(I1);
end