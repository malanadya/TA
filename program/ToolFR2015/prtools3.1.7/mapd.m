%MAPD Map data on given mapping
%
%	D = MAPD(A,W)
%
% Maps the dataset A on the mapping W. If A is a M x K dataset,
% and W is a K x C mapping then D is a M x C dataset.
%
% This command may also be written as:
%
%	D = A*W
%
function d = mapd(a,w)
d = a*w;
