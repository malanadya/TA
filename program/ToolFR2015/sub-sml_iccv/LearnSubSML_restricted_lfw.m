 
% Verification in restricted setting on LFW dataset using Sub-SML 
% Qiong, 19/03/2013

Thismethod = 5;
pair_metric_learn_algs_vec = {'pca', 'Intrapca', 'SubML', 'SubSL', 'SubSML'};
pair_metric_learn_algs = pair_metric_learn_algs_vec{Thismethod};
pcadim_vec = 300.*[1,1,1,1,1];           % PCA dimension to evaluatePca
pca = pcadim_vec(Thismethod);

di = pca;
N = 300; 

ggamma = 10; beta = 10;

options.display = 1;
options.tol = 1e-5;
options.maxiter = 1e5;

CRTT_sim2 = zeros(10,1); 

fprintf('********Dim = %d, training DML...\n', pca);

 for cFold = 1:10

    fprintf('Fold %d \n', cFold);
     
    load(['PairF' num2str(N) num2str(cFold) '.mat']);
    
    Data = double(Data(:,1:pca)); 
    DataTT1 = double(DataTT1(1:pca,:)); 
    DataTT2 = double(DataTT2(1:pca,:)); 
    
    switch pair_metric_learn_algs
        
        case('pca')
            
            LData = Normalisation(Data); 
            LDataTT1 = Normalisation(DataTT1')'; 
            LDataTT2 = Normalisation(DataTT2')';
             
            MT = eye(pca); GT = eye(pca);
    
        case('Intrapca')
            
            nos_sim = size(SS,1); ut = ones(nos_sim,1);
                                                         
            XS = SODW(Data', SS(:,1), SS(:,2), ut);
            XS = (XS + XS')./2 + 1e-6.*eye(size(Data,2)); 
            LS = chol(XS,'lower'); result.LS  =  LS ;
       
            LData = (linsolve(result.LS,Data'))';
            LData = Normalisation(LData); 
            LDataTT1 = linsolve(result.LS,DataTT1); 
            LDataTT1 = Normalisation(LDataTT1');
            LDataTT1 = LDataTT1';
            LDataTT2 = linsolve(result.LS,DataTT2);
            LDataTT2 = Normalisation(LDataTT2');
            LDataTT2 = LDataTT2';
 
            MT = eye(di); GT = eye(di);
        
        case('SubSML')
                     
            result = SubSML_FISTA(Data, SS, DD, ggamma, beta, di, options);
            LData = (linsolve(result.LS,Data'))';
            LData = Normalisation(LData); 
            LDataTT1 = linsolve(result.LS,DataTT1); 
            LDataTT1 = Normalisation(LDataTT1');
            LDataTT1 = LDataTT1';
            LDataTT2 = linsolve(result.LS,DataTT2);
            LDataTT2 = Normalisation(LDataTT2');
            LDataTT2 = LDataTT2';
            
            MT = result.MM; GT = result.GG;
            
        case('SubML')
            
            result = SubML_FISTA(Data, SS, DD, beta, di, options);
            LData = (linsolve(result.LS,Data'))';
            LData = Normalisation(LData); 
            LDataTT1 = linsolve(result.LS,DataTT1); 
            LDataTT1 = Normalisation(LDataTT1');
            LDataTT1 = LDataTT1';
            LDataTT2 = linsolve(result.LS,DataTT2);
            LDataTT2 = Normalisation(LDataTT2');
            LDataTT2 = LDataTT2';
    
            MT = result.MM; GT = zeros(di);
            
        case('SubSL')
            
            result = SubSL_FISTA(Data, SS, DD, beta, di, options);
            LData = (linsolve(result.LS,Data'))';
            LData = Normalisation(LData); 
            LDataTT1 = linsolve(result.LS,DataTT1); 
            LDataTT1 = Normalisation(LDataTT1');
            LDataTT1 = LDataTT1';
            LDataTT2 = linsolve(result.LS,DataTT2);
            LDataTT2 = Normalisation(LDataTT2');
            LDataTT2 = LDataTT2';
    
            MT = zeros(di); GT = result.GG;
                 
    end
    
    
    NPair = size(LDataTT1,2)/2;
    SS_test = [1:NPair; 2*NPair+ 1: 3*NPair]'; 
    DD_test = [NPair+ 1:2*NPair; 3*NPair+ 1: 4*NPair]';
        
    [CRTT_sim2(cFold), ROCTT, ScoreTN, ScoreTT, Threshold] = verification_metric_similarity_test_simplified(MT, GT,...
        LData, SS, DD, [LDataTT1';LDataTT2'], SS_test, DD_test);
        
    scoreS{cFold}=ScoreTT-Threshold;
    %accuracy semplicemente calcolata con:
%     (sum(ScoreTTPOS>Threshold)+sum(ScoreTTNEG<Threshold))/600
    
 end
 save C:\Lavoro\Implementazioni\FaceRecognition2015\Scores2015\SubSML_sift.mat scoreS
 ACC = mean(CRTT_sim2); STD = std(CRTT_sim2)./sqrt(10); 
  
     