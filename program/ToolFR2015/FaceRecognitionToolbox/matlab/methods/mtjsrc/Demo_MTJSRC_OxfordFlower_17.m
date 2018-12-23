%   Demo for OxfordFlower_17
%   Perform multi-task joint sparse representation and classification to
%   combine multiple feature kernels
%   kernels
%
%   Author:: Xiao-Tong Yuan

% AUTORIGHTS
% Copyright (C) 2009-10 
% Learning & Vision Research Group, ECE,Dept. NUS
% Xiao-Tong Yuan (Dr.), eleyuanx@nus.edu.sg

fea_names = {'hog','hsv','siftint','siftbdy','colourgc','shapegc','texturegc'};

fprintf('--------- Task (feature) confidence --------- \n');
for (i=1:size(fea_names,2))
    fprintf('%s : %f/7 \n', fea_names{i}, weight_task{i});
end

cr_rate = [];
for (split_id =[1:3])

    load(['..\data\tasks\task_',int2str(split_id),'.mat']);
    
    fprintf('-------------train/test split #%d:------------- \n', split_id);
    fprintf('Number of test images processed: ');
        
    K = length(Q);
    
    testConf = zeros(numClasses);
    
    for (l=1:size(Y_task_total{1},2))
        
        Y_task = cell(K,1);
        for (k=1:K)
            Y_task{k} = Y_task_total{k}(:,l);  
        end     
        
        %----------Joint sparse representation and classification---------------

        R = X_task;
        opt = [];
        
        opt.eta = 0.002;
        opt.lambda = 0.001;
        opt.ite_num = 5;
        opt.kernel_view = 1;
       
        W = MTJSRC_APG(X_task, Y_task, Q, group_index_task, opt);
    
          
        predClass = Classify(Y_task, X_task, group_index_task, weight_task, W);
        
        
        gtClass = gnd_Test(l);
        
        testConf(gtClass, predClass) = testConf(gtClass, predClass) + 1;
       
       if (mod(l,10)==0)
            fprintf('%d ', l);
            if (mod(l,200)==0)
                fprintf('\n \f');
            end
        end
    end
    
    testConf = testConf./ (sum(testConf,2) * ones(1, numClasses)) ;
    
    cr_rate = [cr_rate, mean(diag(testConf))];
    fprintf('\n Accuracy: %f \n \f',mean(diag(testConf)));
end

fprintf('Mean: %1.4f \n', mean(cr_rate));
fprintf('Variance: %1.4f \n', std(cr_rate));

filename = ['..\result\recognition.mat'];
save(filename, 'cr_rate');
