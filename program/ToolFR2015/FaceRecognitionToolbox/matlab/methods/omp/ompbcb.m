function [A,cont]=OMP(D,X,L, bK); 
%=============================================
% Sparse coding of a group of signals based on a given 
% dictionary and specified number of atoms to use. 
% input arguments: 
%       D - the dictionary (its columns MUST be normalized).
%       X - the signals to represent
%       L - the max. number of coefficients for each signal.
% output arguments: 
%       A - sparse coefficient matrix.
%=============================================

if ~exist('bK', 'var')
    bK = 256;
end
cont = 0;

if bK ~= 1
    [n,P]=size(X);
    [n,K]=size(D);
    A = sparse(size(D,2),size(X,2));
    allK = bK:bK:P;
    for k=allK
        a=[];
        x=X(:,k-bK+1:k);
        residual=x;
        indx=zeros(L,bK);
        breakOn = zeros(bK,1);
        At = zeros(L,bK);
        J = zeros(bK,1);
        for j=1:1:L,
            proj=D'*residual;
            for m = 1:bK
                if breakOn(m), cont = cont + 1; continue; end
                [maxVal,pos]=max(abs(proj(:,m)));
                pos=pos(1);
                indx(j,m)=pos;
                a=pinv(D(:,indx(1:j,m)));
                a=a*x(:,m);
                At(1:j,m) = a;
                residual(:,m)=x(:,m)-D(:,indx(1:j,m))*a;
                J(m) = j;
                if sum(residual(:,m).^2) < 1e-6
                    breakOn(m) = 1;
                end
            end
        end;
        for kk = 1:bK
            temp=zeros(K,1);
            %temp(indx(1:j))=a;
            temp(indx(1:J(kk),kk)) = At(1:J(kk),kk);
            A(:,k-bK+kk)=sparse(temp);
        end
    end;
    
    for k=allK(end):1:P,
        a=[];
        x=X(:,k);
        residual=x;
        indx=zeros(L,1);
        for j=1:1:L,
            proj=D'*residual;
            [maxVal,pos]=max(abs(proj));
            pos=pos(1);
            indx(j)=pos;
            a=pinv(D(:,indx(1:j)))*x;
            residual=x-D(:,indx(1:j))*a;
            if sum(residual.^2) < 1e-6
                break;
            end
        end;
        temp=zeros(K,1);
        temp(indx(1:j))=a;
        A(:,k)=sparse(temp);
    end;
else
    [n,P]=size(X);
    [n,K]=size(D);
    A = sparse(size(D,2),size(X,2));
    for k=1:1:P,
        a=[];
        x=X(:,k);
        residual=x;
        indx=zeros(L,1);
        for j=1:1:L,
            proj=D'*residual;
            [maxVal,pos]=max(abs(proj));
            pos=pos(1);
            indx(j)=pos;
            a=pinv(D(:,indx(1:j)))*x;
            residual=x-D(:,indx(1:j))*a;
            if sum(residual.^2) < 1e-6
                break;
            end
        end;
        temp=zeros(K,1);
        temp(indx(1:j))=a;
        A(:,k)=sparse(temp);
    end;
end
return;


% function [A]=OMP(D,X,L); 
% %=============================================
% % Sparse coding of a group of signals based on a given 
% % dictionary and specified number of atoms to use. 
% % input arguments: 
% %       D - the dictionary (its columns MUST be normalized).
% %       X - the signals to represent
% %       L - the max. number of coefficients for each signal.
% % output arguments: 
% %       A - sparse coefficient matrix.
% %=============================================
% [n,P]=size(X);
% [n,K]=size(D);
% A = sparse(size(D,2),size(X,2));
% for k=1:1:P,
%     a=[];
%     x=X(:,k);
%     residual=x;
%     indx=zeros(L,1);
%     for j=1:1:L,
%         proj=D'*residual;
%         [maxVal,pos]=max(abs(proj));
%         pos=pos(1);
%         indx(j)=pos;
%         a=pinv(D(:,indx(1:j)))*x;
%         residual=x-D(:,indx(1:j))*a;
%         if sum(residual.^2) < 1e-6
%             break;
%         end
%     end;
%     temp=zeros(K,1);
%     temp(indx(1:j))=a;
%     A(:,k)=sparse(temp);
% end;
% return;
