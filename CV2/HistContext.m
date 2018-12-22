% Based on the method proposed in [38] permits, it encodes each region a 30 dimensional feature vector, to encode spatial co-occurrence statistics of visual patterns so providing discriminative spatial information. 

function NH=HistContext(H)
%H(i,j) stores to which histogram bin is assigned the patch (i,j)

%NH is the 30 dimensional feature vector

%6 different neighbours
shape{1}=[-1 0 1;0 0 0];
shape{2}=[0 0 0;-1 0 1];
shape{3}=[-1 0 0;0 0 -1];
shape{4}=[0 0 1;-1 0 0];
shape{5}=[-1 0 0;0 0 1];
shape{6}=[0 0 1;1 0 0];

NH=zeros(6,5);%30 dimensional feature vector

for i=2:size(H,1)-1
    for j=2:size(H,2)-1
        
        for sh=1:6%for all the 6 different neighbours
            B=[H(shape{sh}(2,1)+i, shape{sh}(1,1)+j) H(shape{sh}(2,2)+i, shape{sh}(1,2)+j) H(shape{sh}(2,3)+i, shape{sh}(1,3)+j)];
            OMO=[isequal(B(1),B(2)) isequal(B(1),B(3)) isequal(B(2),B(3))];
            
            %considero 5 tipi di omogeneità
            VAL1=sum(OMO);
            if VAL1==3%tutti e 3 uguali
                NH(sh,1)=NH(sh,1)+1;continue
                
            elseif VAL1==0%tutti e 3 diversi
                NH(sh,2)=NH(sh,2)+1;continue
            end
            
            if VAL1==1 & OMO(3)==1
                NH(sh,3)=NH(sh,3)+1;continue
            end
                
            if VAL1==1 & OMO(1)==1
                NH(sh,4)=NH(sh,4)+1;continue
            end
            
            if VAL1==1 & OMO(2)==1
                NH(sh,5)=NH(sh,5)+1;continue
            end
            
        end
        
    end
end

NH=NH(:);
