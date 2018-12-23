
function [L] = testdLoris(a)


if ~isa(a,'dataset')
   error('Dataset expected')
end
[nlab,lablist,m,k,c,prob] = dataset(a);
L = classdKmost(a);
%in L le classi  alle quali i patter sono assegnati
if k>2
    L=L(:,k);
end
return

