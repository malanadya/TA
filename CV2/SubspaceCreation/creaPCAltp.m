function [O]= creaPCAltp(nmax,dimfeat,str,elenco,NCL) 
% str: url of the images 
% dimfeat: dimension of the descriptor
% nmax: number of sub-windows to extract for building the projection
% matrix
% elenco: the directories where are stored the images of the different
% classes
% NCL: number of class

O=single(zeros(nmax,dimfeat)); %to store the patches then used for matrix projection
cont=1;

for i=1:NCL
    d=dir(strcat(str,elenco{i}));
    v(i,length(d))=0;   %to check if an image is extracted two times
end

%mapping for LTP
mapping1=getmapping011(8,'u2');
mapping2=getmapping011(16,'u2');

for i=1:100000

    indice_classe=fix(NCL*rand(1)+1);
    class_random=elenco(indice_classe); %a class is randomly choosen

    class_random=strcat(str,class_random);
    d=dir(class_random{1});t=1;
    img_random=fix((length(d)-3)*rand(1)+3); %an image is randomly choosen

    cont1=0;
    while v(indice_classe,img_random)==1 %if that image is already extracted we choose another image

        class_random=elenco(fix(NCL*rand(1)+1)); 
        class_random=strcat(str,class_random);
        d=dir(class_random{1});t=1;
        img_random=fix((length(d)-3)*rand(1)+3);

        if cont1==5%to avoid loop
            break;
        end
    end

    v(indice_classe,img_random)=1; %to avoid to extract two times the same image
    I1=imread(strcat(class_random{1},'\',d(img_random).name),'jpg');

    %resize of the immage
    if min(size(I1))<50
        dim=50/min(size(I1));
        I1=imresize(I1,[size(I1,1)*dim  size(I1,2)*dim]);
    end

    step1=ceil(size(I1,1)/10);
    step2=ceil(size(I1,2)/10);
    passo=ceil(min([step1 step2]./2));

    descr1_final=[];
    string_a=[];
    for a=1:passo:size(I1,1)-step1-1
        for b=1:passo:size(I1,2)-step2-1
            T=I1(a:a+step1,b:b+step2);
            descr1_final=[descr1_final; [tesi(T,[3 ],8,'ci',1,0,0,mapping1,'nh') tesi(T,[ 3],16,'ci',2,0,0,mapping2,'nh')]];%here we use LTP
            %if you want to use LPQ:descr1_final=[descr1_final; [ lpqMIO(T, 3)']'];
        end
    end

    t=1;
    patch=[];
    for j=1:5:size(descr1_final,1) %only the 20% of the regions extracted are retained
        patch(t,:)=descr1_final(j,:);t=t+1;
    end

    O(cont:cont+size(patch,1)-1,:)=patch; %to store the patches
    cont=cont+size(patch,1); %to count the number of patches

    if cont>=nmax %until nmax sub-windows are extracted
        break;
    end
end

end

