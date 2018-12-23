function score = Score_SML(X, inda, indb, M, G)
% Data X = (x_1, x_2, ..., x_N)'
% Similarity score S(inda,indb) = f_{M, G}(inda,indb) = -dist(inda,indb)+
% cos(inda,indb), 
% where dist(inda,indb) = (X(inda,:)- X(indb,:))*M*(X(inda,:)- X(indb,:))'
% cos(inda,indb) = X(inda,:)*M*X(indb,:)'

L = size(inda,1);
dist = zeros(L, 1); sim = zeros(L, 1);
for l = 1: L
    dist(l) = (X(inda(l),:)- X(indb(l),:))*M*(X(inda(l),:)- X(indb(l),:))';
    sim(l) = X(inda(l),:)*G*X(indb(l),:)';
end

score = -dist+ sim;