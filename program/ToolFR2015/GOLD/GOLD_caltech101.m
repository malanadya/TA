clear
ntrain = [5 10 15 20 25 30];
%ntrain=[30];
nsplit = 5;
result_num = 1; 
accuracy = zeros(size(ntrain,2),nsplit);
results = zeros(size(ntrain,2));
for kk=ntrain
    for jj=1:nsplit
        fprintf('\n-----------------------------------------------------------\n');
        fprintf('Experiment with %d training samples per class (split %d)\n',kk,jj);
        
        conf.calDir = 'data/caltech-101/101_ObjectCategories' ;
        conf.dataDir = 'data/' ;
        conf.wpgoldsDir = 'data/wpgoldsCaltech-101';
        conf.numTrain = kk ;
        conf.numTest = 50 ;
        conf.numClasses = 102 ;
        conf.numSpatial = [1 2 4] ;
        conf.svm.C = 10 ;
        conf.phowOpts = {'Step', 3} ;
        conf.prefix = ['WPGOLD_split' int2str(jj)];
        conf.randSeed = jj ;
       
        addpath(genpath('./libsvm-3.14/'));
        addpath('./helpfun');


        randn('state',conf.randSeed) ;
        rand('state',conf.randSeed) ;
        vl_twister('state',conf.randSeed) ;

     
        % --------------------------------------------------------------------
        %                                                           Setup data
        % --------------------------------------------------------------------
        
        classes = dir(conf.calDir) ;
        classes = classes([classes.isdir]) ;
        classes = {classes(3:conf.numClasses+2).name} ;

        fprintf('Creating training and testing sets... ');
        images = {} ;
        imageClass = {} ;
        selTrain = [];
        count = 0;
        for ci = 1:length(classes)
          ims = dir(fullfile(conf.calDir, classes{ci}, '*.jpg'))' ;
          testnum = min(conf.numTrain+conf.numTest,length(ims)); 
          testnum = testnum - conf.numTrain;
          ims = vl_colsubset(ims,  conf.numTrain + testnum) ;
          ims = cellfun(@(x)fullfile(classes{ci},x),{ims.name},'UniformOutput',false) ;
          images = {images{:}, ims{:}} ;
          imageClass{end+1} = ci * ones(1,length(ims)) ;
          n_elements= length(ims);
          perm= randsample(n_elements,conf.numTrain);
          selTrain(end+1:end+conf.numTrain)= count+perm;
          count = count + n_elements;
        end
        selTest = setdiff(1:length(images), selTrain) ;
        imageClass = cat(2, imageClass{:}) ;
        fprintf('done.\n');
        
        % --------------------------------------------------------------------
        %                                                   GOLD EXTRACTION
        % --------------------------------------------------------------------

        fprintf('Extracting/loading GOLD descriptors... ');
        
        model.classes = classes ;
        model.phowOpts = conf.phowOpts ;
        model.numSpatial = conf.numSpatial ;

        wpgolds = {} ;
        parfor ii = 1:length(images)
        %for ii = 1:length(images)
            fname_image=fullfile(conf.calDir, images{ii}) ;
            [classeDir, name, ext] = fileparts(images{ii}) ;
            codeDir_temp =  fullfile(conf.wpgoldsDir,classeDir);
            if  ~exist(codeDir_temp,'dir')
                mkdir(codeDir_temp);
            end
            fname_wpgold =fullfile(codeDir_temp, [name '.mat']) ;
            if ~exist(fname_wpgold,'file') 
                im = imread(fname_image) ;
                wpgold=getImageDescriptor_wpgold(model, im);
                iSave(fname_wpgold,wpgold);
            else
                wpgold = iLoad(fname_wpgold,'wpgold');
            end
            wpgolds{ii} = wpgold;
        end
        fprintf('done.\n');
        
        fprintf('L2 normalization... ');
        psix = cat(2, wpgolds{:}) ;
        clear wpgolds;
        % L2 Normalization
        psix = bsxfun(@rdivide, psix, sqrt(sum(psix.^2)));
        psix=zscore(psix);
        fprintf('done.\n');

        % --------------------------------------------------------------------
        %                                                            Train SVM
        % --------------------------------------------------------------------
        fprintf('Training classifiers... ');
        % Libsvm dual
        K = psix(:,selTrain)'*psix(:,selTrain);
        labels = unique(imageClass);

        libsvm = cell(1,length(labels));
        for ci=1:length(labels)
        %parfor ci=1:length(labels)
            labels_cls = -ones(1, size(K,1));
            labels_cls(imageClass(selTrain) == labels(ci)) = 1;
            libsvm{ci} = svmtrain(labels_cls', ...
                    [(1:size(K,1))' K], ...
                    sprintf(' -t 4 -c %f -q', conf.svm.C));
        end
        fprintf('done.\n');

        % --------------------------------------------------------------------
        %                                                Test SVM and evaluate
        % --------------------------------------------------------------------
        fprintf('Testing... ');
        KK = (psix(:,selTrain)'*psix(:,selTest))';
        scoremat = zeros(length(libsvm),size(KK,1));
        for ci=1:length(labels)
            % Use evalc to suppress meaningless default output of
            % svmpredict
            [output, predicted_label, ac, scorevec] = evalc(...
                'svmpredict(zeros(size(KK,1),1), [(1:size(KK,1))'' KK], libsvm{ci})');

            if(libsvm{ci}.Label(1)==-1)
                scorevec = -scorevec;
            end
            scoremat(ci,:) = scorevec';
        end
        fprintf('done.\n');

        fprintf('Evaluating accuracy... ');
        % Estimate the class of the test images
        [drop, imageEstClass] = max(scoremat, [], 1) ;

        % normalize the classification accuracy by averaging over different
        % classes
        labels= 1:max(imageClass);
        acc = zeros(numel(labels), 1);
        for zz = 1 : numel(labels)
            c = labels(zz);
            idx = find(imageClass(selTest) == c);
            curr_pred_label = imageClass(selTest(idx));
            curr_gnd_label = imageEstClass(idx);
            acc(zz) = length(find(curr_pred_label == curr_gnd_label))/length(idx);
        end
        accuracy(result_num,jj) = mean(acc);
        fprintf('done.\n');
        fprintf('Accuracy (this split): %f\n',accuracy(result_num,jj));
   end 
   results(result_num) = mean(accuracy(result_num,:));
   fprintf('Average classification accuracy (%d training samples per class): %f\n',kk, results(result_num));
   result_num = result_num + 1;
end
