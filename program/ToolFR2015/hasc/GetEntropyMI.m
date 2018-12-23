function [ EMIVec ] = GetEntropyMI( feat, max_vector, min_vector, opt )
    
    % Marco San Biagio      Version 1.00
    % Copyright 2013 Marco San Biagio.  [Marco.SanBiagio-at-iit.it]
    % Please email me if you have questions.
    %
    % INPUTS
    % feat             - feat is a 3D matrix representing the features of
    %                    a single patch extracted from the image (w x h x d)
    %
    % OUTPUT
    % EMIvec           - EMI descriptor of size   1 x (d * (d+1) / 2). The final descriptor is vectorized
    %
    % [1] M. San Biagio, M. Crocco, M. Cristani, S. Martelli and V. Murino
    %     Heterogeneous Auto-Similarities of Characteristics (HASC): Exploiting Relational Information for Classification
    %     International Conference on Computer Vision, Proceedings of. 2013.

    EMI = GetEntropyMIMex(feat, max_vector, min_vector, opt.bin);
    EMIVec = GetVectorization( EMI );
    
end