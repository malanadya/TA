function [O]= creaPCAsift(nmax,dimfeat,str,elenco,NCL) 
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

for i=1:100000

    indice_classe=fix(NCL*rand(1)+1);
    class_random=elenco(indice_classe);  %a class is randomly choosen

    class_random=strcat(str,class_random);
    d=dir(class_random{1});t=1;
    img_random=fix((length(d)-3)*rand(1)+3); %an image is randomly choosen

    cont1=0;
    while v(indice_classe,img_random)==1  %if that image is already extracted we choose another image

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


    descr1_final=[];
    string_a=[];

    %SIFT extraction
    [frames,descr1_final,gss,dogss]=sift( I1, 'Verbosity', 0 );
    descr1_final=descr1_final';

    t=1;
    patch=[];
    for j=1:5:size(descr1_final,1) %only the 20% of the regions extracted are retained
        patch(t,:)=descr1_final(j,:);t=t+1;
    end

    if t>1
        O(cont:cont+size(patch,1)-1,:)=patch; %to store the patches
        cont=cont+size(patch,1); %to count the number of patches
    end

    if cont>=nmax %until nmax sub-windows are extracted
        break;
    end
end

end

