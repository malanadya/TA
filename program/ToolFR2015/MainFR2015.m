
%pre-processing of a given image saved in I
I=PrePimageTool(I,metodo);%metodo (values between 1 and 9) permits to choose a different pre-processing approach, see the code of  PrePimageTool.m

%for building artificial poses in LFW we use the matlab function
%fliplr(I)


%for extracting features from a given image/sub-image named IMG
load MAP.mat
feat = FEtool(I,metodo,map1);%map1 is a structure used for extrating POEM features
%metodo (values between 1 and 8) permits to choose a different feature extraction approach, see the code of  FEtool.m
%notice that Monogenic has three components: amplitude, phase, and
%orientation components. These are extracted separately with metodo=4;
%metodo=5; metodo=6. Then a different SVM/SML (for LFW) o a distance (for
%FERET) is run for each of the three components, these three similarities are
%finally combined by sum rule for obtaining the performance of the full
%monogenic descriptor
%Notice that the parameters of the feature extractor are those used in the
%papers, when the PCA reduction detailed in section 2.5 is performed

%notice that in LFW, using SVM as classifier, the vector that describe a given match, between two
%images described by the feature vectors feat and feat1, is obtained in the
%following way:
if length(feat)<length(feat1)
    feat(length(feat1))=0;
end
if length(feat1)<length(feat)
    feat1(length(feat))=0;
end
if isrow(feat)
    feat=feat';
end
if isrow(feat1)
    feat1=feat1';
end
feat2=(feat1-feat).^2;
feat2=feat2./(feat+feat1);
feat2(find(isnan(feat2)))=0;
feat2(find(isinf(feat2)))=0;
%feat2 descrive the given match

%%%%%%%%%% FEATURE TRANSFORM USING SML AS CLASSIFIER %%%%%%%%%%%%%%%%%%%%%%%%%%%
%for calculating whitened PCA subspace projection,
%Let us define X a matrix where the training patterns are stored
%notice that we have used this approach for ALL the feature extractor
X=X';
N=size(X,2);%number of patterns
m=mean(X,2);
for i=1:N
    X(:,i)=double(X(:,i)) - m;
end
L=(X'*X)/N;
[V D] = eig(L);  % L*V = D*V
[eigVecs eigVals] = sortem(V,D);
clear V
clear D
clear L
%Eigenvectors of C matrix
u=[];
for i=1:300
    temp=eigVals(i,i);
    u=[u (X*eigVecs(:,i))./temp];  % normalization for whitened PCA
end
V=single(u);
clear u
X=V'*X;
meanAllPOEM=m;
X=X';
%then to project a test image, given the projection built with the training
%data, described by the features stored in feat2:
feat2=feat2-meanAllPOEM;
feat2=V'*feat2;

%%%%%%%%%% training and testing SML %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ggamma = 10; beta = 10;
options.display = 1;
options.tol = 1e-5;
options.maxiter = 1e5;

%training
%Let us define Data a the matrix that contains the training set
%SS are the index of the couples of genuine matches
%DD are the index of the couples of impostor matches
%e.g. we have 100 matches (so we have 200 images), where the first 50
%matches are genuine and the matches between 51 and 100 are impostors
%in this way the size of Data will be 200 x "number of features"
%in this way the size of SS and DD will be 50 x 2, 50 is the number of
%matches, SS(x,1) and SS(x,2) are the images matched (genuine match) in the x-th match
result = SubSML_FISTA(Data, SS, DD, ggamma, beta, 0, options); %SS and DD: the index of the similar/dissimilar pairs.
LData = (linsolve(result.LS,Data'))';
LData = Normalisation(LData);
                                    
%test
%let use suppose that 
%DataTT1 stores the first image of the couple of the images to match
%DataTT2 stores the second image of the couple of the images to match
%i.e. the two images that build the i-th match are stored in 
%DataTT1(:,i) and DataTT2(:,i) 

LDataTT1 = linsolve(result.LS,DataTT1);
LDataTT1 = Normalisation(LDataTT1');
LDataTT1 = LDataTT1';
LDataTT2 = linsolve(result.LS,DataTT2);
LDataTT2 = Normalisation(LDataTT2');
LDataTT2 = LDataTT2';

MT = result.MM; GT = result.GG;
NPair = size(LDataTT1,2)/2;
SS_test = [1:NPair; 2*NPair+ 1: 3*NPair]';%genuine 
DD_test = [NPair+ 1:2*NPair; 3*NPair+ 1: 4*NPair]';%impostor

[CRTT_sim2, ROCTT, ScoreTN, ScoreTT, Threshold] = verification_metric_similarity_test_simplified(MT, GT,...
    LData, SS, DD, [LDataTT1';LDataTT2'], SS_test, DD_test);

score=ScoreTT-Threshold;%final scores obtained by SML














