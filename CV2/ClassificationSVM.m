%let us define TR the trainig set and TE the test set
%let us define y the labels of the training data
%let us define yy the labels of the test data
%notice that the values of the labels are {1,-1} and, since these problems
%have several classes, you should run several SVMs (they are bi-class
%classifiers), in the paper we have used the one vs all approach

%to normilize the data between 0 and 1 using only the training data
massimo=max(TR)+0.00001;
minimo=min(TR);
training=[];
testing=[];
for i=1:size(TR,2)
    training(1:size(TR,1),i)=double(TR(1:size(TR,1),i)-minimo(i))/(massimo(i)-minimo(i));
end
for i=1:size(TE,2)
    testing(1:size(TE,1),i)=double(TE(1:size(TE,1),i)-minimo(i))/(massimo(i)-minimo(i));
end
tra=[];
TR=training;
TE=testing;

%we used HistogramKernel tool for rbf, polynomial linear and histogram
%intersection kernel
cd C:\MATLAB1\TOOL\HistogramKernel\source\

model = svmtrain(double([y]'), double([TR]),'-t 2 -g 0.1 -c 1000');%e.g. we used rbf kernel with gamma=0.1 and C=1000
[PreLabels, accuracy, DecisionValue] = svmpredict(double([yy]'),double([TE]),  model);
%DecisionValue stores the scores

model= svmtrain(double([y]'), double([TR]),'-t 4 -c 0.25');%intersection kernel


%we used fast-additive-svms for chi-square kernel
cd C:\MATLAB1\TOOL\fast-additive-svms\libsvm-mat-3.0-1\

model = svmtrain(double([y]'), double([TR]),'-t 6 -g 1 -c 100');
[PreLabels, accuracy, DecisionValue] = svmpredict(double([yy]'),double([TE]),  model);
%DecisionValue stores the scores



%notice that sometimes there are some problems with the scores, to check
%and to solve:
if DecisionValue(find(PreLabels==1))<0
    DecisionValue=DecisionValue*-1;
end
if sum(DecisionValue(find(PreLabels==-1)))>0
    DecisionValue=DecisionValue*-1;
end