function [ output_args ] = Untitled2( input_args )
%for calculating whitened PCA subspace projection,
%Let us define X a matrix where the training patterns are stored
N=size(X,2);
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
for i=1:size(eigVecs,2)
    if eigVals(i,i)>10e-4
        temp=eigVals(i,i);
        u=[u (X*eigVecs(:,i))./temp];  % normalization for whitened PCA
    end
end


PPOEM=single(u);
clear u
X=PPOEM'*X;
meanAllPOEM=m;
X=X';

else
    
    PPOEM=pca(dataset(X),0.99);
    X=+(PPOEM*dataset(X));
    meanAllPOEM=0;

end

