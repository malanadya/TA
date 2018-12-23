function [NV,ND] = sortem(V,D)

if nargin ~= 2
 error('Must specify vector matrix and diag value matrix')
end;

dvec = diag(D);
NV = zeros(size(V));
[dvec,index_dv] = sort(dvec);
index_dv = flipud(index_dv);
for i = 1:size(D,1)
  ND(i,i) = D(index_dv(i),index_dv(i)); %valeur propre ds l ordre
  NV(:,i) = V(:,index_dv(i));%vecteur propre ds l ordre correspondant
end;
