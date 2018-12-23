function C = makeposdef(cov)
    min_eig_threshold =0.0001;
    sizeD=size(cov,1);
    D = 0.000000001*eye(sizeD, sizeD);
    cov_org = cov;
    while true
        min_eig = min(eig(cov));
        if (min_eig>min_eig_threshold)
            break;
        end
        cov = cov_org + D;
        D = D * 10;
    end
    C=cov;
end