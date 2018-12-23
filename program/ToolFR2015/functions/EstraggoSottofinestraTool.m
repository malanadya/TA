function I=EstraggoSottofinestraTool(I1,mark,qualeLandmark,dim);

I=I1;
current_shape=mark(qualeLandmark,:);

base(1)= current_shape(2)-dim;
base(2)= current_shape(2)+dim;
base(3)= current_shape(1)-dim;
base(4)= current_shape(1)+dim;

if base(1)<=1
    base(1)=1;
end
if base(3)<=1
    base(3)=1;
end
if base(2)>size(I,1)
    base(2)=size(I,1);
end
if base(4)>size(I,2)
    base(4)=size(I,2);
end
base=round(base);
I=I(base(1):base(2),base(3):base(4),:);
I(dim*2+1,dim*2+1,:)=0;


