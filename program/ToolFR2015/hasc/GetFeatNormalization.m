function [feat,max_vector,min_vector] = GetFeatNormalization(feat,opt)

    % Marco San Biagio      Version 1.00
    % Copyright 2013 Marco San Biagio.  [Marco.SanBiagio-at-iit.it]
    % Please email me if you have questions.
    %
    % INPUTS
    % feat             - (w x h x d) Matrix containing the features extracted
    %                    from the image
    % opt              - stucture containing all the parameters of the function demo.m 
    %
    % OUTPUT
    % feat   	       - (w x h x d) Matrix containing the features normalized
    % max_vector       - Vector containing the maximum values of each feature considering all images
    % min_vector       - Vector containing the minimum values of each feature considering all images
    %
    %
    % [1] M. San Biagio, M. Crocco, M. Cristani, S. Martelli and V. Murino
    % Heterogeneous Auto-Similarities of Characteristics (HASC): Exploiting Relational Information for Classification
    % International Conference on Computer Vision, Proceedings of. 2013.

    mean_vector = zeros(1,opt.NoFeat);
    std_vector  = zeros(1,opt.NoFeat);
    max_vector  = zeros(1,opt.NoFeat);
    min_vector  = zeros(1,opt.NoFeat);
    
    [x,y,~] = size(feat);
    
    for nof = 1 : opt.NoFeat
                
        % for multiple images, feat is a cell array of 3d matrices and tmp
        % is a vector containing the concatenation of the "nof" feature;
        % for multiple images uncomment lines 35-38 and comment line 39
        
        % tmp = [];
        % for i = 1 : number_of_images
        % tmp = [tmp single(reshape(feat{i}(:,:,nof),1,x*y))];
        % end
        tmp = single(reshape(feat(:,:,nof),1,x*y));
        
        % Mean, Std, Max and Min are calculated over all the images of the training set for each feature        
        mean_vector(1,nof) = mean(tmp(1,:));
        std_vector(1,nof) = std(tmp(1,:));
        
        max_vector(1,nof) = max(tmp(1,:));
        min_vector(1,nof) = min(tmp(1,:));
        
    end
    
end