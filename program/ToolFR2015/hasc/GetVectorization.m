function [ vec ] = GetVectorization( A )
    
    % Marco San Biagio      Version 1.00
    % Copyright 2013 Marco San Biagio.  [Marco.SanBiagio-at-iit.it]
    % Please email me if you have questions.
    %
    % INPUTS
    % A                - matrix descriptor
    %
    % OUTPUT
    % vec              - descriptor vectorized 
    %
    % [1] M. San Biagio, M. Crocco, M. Cristani, S. Martelli and V. Murino
    % Heterogeneous Auto-Similarities of Characteristics (HASC): Exploiting Relational Information for Classification
    % ICCV 2013
    
    vec = GetVectorizationMex(A);

end

