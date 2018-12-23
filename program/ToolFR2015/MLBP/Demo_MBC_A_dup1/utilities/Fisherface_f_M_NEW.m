function [disc_set,disc_value,train_mean]=Fisherface_f_M_NEW(Train_SET, Eigen_NUM, Axes_NUM,labels)

if nargin < 3 
    error('Not enought arguments!'); 
elseif nargin < 4
    Axes_NUM=min([Eigen_NUM, Class_NUM-1]); 
end

%-------------------assign train_dat and tr_labels---------------------
[sort_labels,I]= sort(labels,'ascend');
sort_Train_SET = Train_SET(:,I);
newlabels = [1];
i = 1; id = 1;
while i<size(sort_labels,2)
    i = i+1;
    if sort_labels(i)==sort_labels(i-1)
        newlabels = [newlabels id];
    else
        id = id +1;
        newlabels = [newlabels id];
    end
end

Class_NUM = max(newlabels);
Train_SET = sort_Train_SET;
clear I labels sort_Train_SET sort_labels;
train_mean = [];
for tem_i = 1:size(Train_SET,1)
        tem_i
        tem = single(Train_SET(tem_i,:))';
        tmean = mean(tem);
        t_std = std(tem);
        train_mean = [train_mean;tmean];
        Train_SET(tem_i,:) = single(((tem-tmean))');
end
%-------------------assign train_dat and tr_labels---------------------


[NN,Train_NUM]=size(Train_SET);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Eigenface,or PCA
if NN<=Train_NUM
    
   Mean_Image = mean(Train_SET,2);
   
   num_step = 10;
   step = floor(Train_NUM/num_step);
   R = zeros(NN);
   for step_i = 1:num_step
       if step_i~=num_step
       Tem_Train_SET = Train_SET(:,(step_i-1)*step+1:step_i*step);
       Tem_Train_SET = double(Tem_Train_SET) - Mean_Image*ones(1,size(Tem_Train_SET,2));
       R= R+Tem_Train_SET*Tem_Train_SET'/(Train_NUM-1);
       else
       Tem_Train_SET = Train_SET(:,(step_i-1)*step+1:end);
       Tem_Train_SET = double(Tem_Train_SET) - Mean_Image*ones(1,size(Tem_Train_SET,2));
       R= R+Tem_Train_SET*Tem_Train_SET'/(Train_NUM-1);
       end
   end
   
   Matrix_rank=rank(R);
   if Eigen_NUM>Matrix_rank
    Eigen_NUM=Matrix_rank;
   end
    
   [V,S] = Find_K_Max_Eigen(R,Eigen_NUM);
   disc_value = S;
   disc_set = V;
   New_Train_SET = disc_set'*double(Train_SET);
   Train_SET=New_Train_SET; % this Train_SET is used for the following operation
   clear New_Train_SET R Mean_Image Tem_Train_SET V disc_value
else
   Train_SET = single(Train_SET);
   R=Train_SET'*Train_SET; % size of (Train_NUM,Train_NUM)

   unit = ones(Train_NUM, Train_NUM)/Train_NUM;
   % centering in feature space!
   R_central = R - unit*R - R*unit + unit*R*unit;

    Matrix_rank=rank(R_central);
    if Eigen_NUM>Matrix_rank
    Eigen_NUM=Matrix_rank;
    end

   [V,S]=Find_K_Max_Eigen(R_central,Eigen_NUM);
   disc_value=S;

   disc_set=zeros(Train_NUM,Eigen_NUM);
   for k=1:Eigen_NUM
   disc_set(:,k)=(1/sqrt(disc_value(k)))*V(:,k);
   end

   New_Train_SET=disc_set'*R; % this Train_SET is used for the following operation
   disc_set=Train_SET*disc_set;
   Train_SET=New_Train_SET; % this Train_SET is used for the following operation
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LDA
dim=Eigen_NUM; % the dimension of the column of the Train_SET

% SN=Train_NUM/Class_NUM; % SN denote the sample number per class

% to evaluate class_mean
k=1;
class_mean=zeros(dim,Class_NUM);
for s=1:Class_NUM
    class_data = Train_SET(:,newlabels==s);
    class_mean(:,s)=mean(class_data,2);
end

% to evaluate Sb
S=zeros(dim,dim);
total_mean=mean(Train_SET,2);
for t=1:Class_NUM
   V=class_mean(:,t)-total_mean;
   class_data = Train_SET(:,newlabels==t);
   S=S+size(class_data,2)*V*V';
end
Sb=S/Train_NUM;

%Sb=Sb+0.001*eye(dim,dim)*trace(Sb);

% to evaluate Sw
S=zeros(dim,dim);
for s=1:Class_NUM
    temp=class_mean(:,s);
    class_data = Train_SET(:,newlabels==s);
    for t=1:size(class_data,2)
      V=class_data(:,t)-temp;
      S=S+V*V';
   end
end
Sw=S/Train_NUM;

% Sw=Sw+0.001*eye(dim,dim)*trace(Sw); % It seem 0.01 is best for FERET database
% St=Sb+Sw; 

if Axes_NUM>(Class_NUM-1)
   Axes_NUM=Class_NUM-1;
end
if Axes_NUM>Eigen_NUM
   Axes_NUM=Eigen_NUM;
end

% to get the generalized eigenvectors and eigenvalues
[disc_set1,disc_value1]=Find_K_Max_Gen_Eigen(Sb,Sw,Axes_NUM);
disc_set=disc_set*disc_set1;
disc_value=disc_value1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Eigen_Vector,Eigen_Value]=Find_K_Max_Eigen(Matrix,Eigen_NUM)

[NN,NN]=size(Matrix);
[V,S]=eig(Matrix); %Note this is equivalent to; [V,S]=eig(St,SL); also equivalent to [V,S]=eig(Sn,St); %

S=diag(S);
[S,index]=sort(S);

Eigen_Vector=zeros(NN,Eigen_NUM);
Eigen_Value=zeros(1,Eigen_NUM);

p=NN;
for t=1:Eigen_NUM
    Eigen_Vector(:,t)=V(:,index(p));
    Eigen_Value(t)=S(p);
    p=p-1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Eigen_Vector,Eigen_Value]=Find_K_Max_Gen_Eigen(Matrix1,Matrix2,Eigen_NUM)

[NN,NN]=size(Matrix1);
[V,S]=eig(Matrix1,Matrix2); %Note this is equivalent to; [V,S]=eig(St,SL); also equivalent to [V,S]=eig(Sn,St); %

S=diag(S);
[S,index]=sort(S);

Eigen_Vector=zeros(NN,Eigen_NUM);
Eigen_Value=zeros(1,Eigen_NUM);

p=NN;
for t=1:Eigen_NUM
    Eigen_Vector(:,t)=V(:,index(p));
    Eigen_Value(t)=S(p);
    p=p-1;
end