%SUBSM Find subspace map
%
%	[W,alf] = subsm(A,n)
%
% A n-dimensional subspace map for the dataset A is found using PCA,
% such that it contains the origin. All object in A are normalized
% first on unit length. The explained variance is returned in alf.
%
%	[W,n] = subsm(A,alf)
%
% In this case a subspace explaining at least a fraction alf of the 
% variance is determined. In n the subspace dimensionality is returned.
%
% Note that the resulting eigenvectors can be made explicite by a
% back projection of the axes into the original space by
% e = +(eye(n)*W')
%
% See datasets, mappings, subsc, fisherm, klm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [w,alf] = subsm(a,n);
b = normm(+a,2);
%Normalizes the distances of all objects in the dataset A such that their Minkowski-p distance to the origin is one
b = [b;-b];%creo per ogni pattern una "versione" con segno negativo, così ho media zero
v = reducm(b);
[e,alf] = klm(b*v,min(n,size(v,2)));%b*v serve a portare lo spazio originario nel sottospazio definito da reducm
%e la normale proiezione
w = v*e;%in questo modo applicando w a pattern del test set c effettuo c*v*e che è equivalente ai pattern del training a cui applico
%prima b*v poi calcolo e
