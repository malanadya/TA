function vec = GetTanProjection (A)
    
    % Marco San Biagio      Version 1.00
    % Copyright 2013 Marco San Biagio.  [Marco.SanBiagio-at-iit.it]
    % Please email me if you have questions.
    %
    % INPUTS
    % A                - matrix descriptor
    %
    % OUTPUT
    % vec              - descriptor projected and vectorized
    %
    % [1] M. San Biagio, M. Crocco, M. Cristani, S. Martelli and V. Murino
    % Heterogeneous Auto-Similarities of Characteristics (HASC): Exploiting Relational Information for Classification
    % ICCV 2013
    
    % Projection on Tangent Space
    [U,S] = eig(A);

    log_inner = U*diag(log(diag(S)))*U';
    diago     = diag(diag(log_inner));
    inner     = (log_inner - diago).*sqrt(2) + diago;
    
    vec = GetVectorization( inner );

end