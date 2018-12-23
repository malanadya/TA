%DATASET Conversion of affine mapping to dataset
%
%	a = dataset(w)
%
% If w is a m x k affine mapping, the axes of the map
% are returned as a m x k dataset a.

function a = dataset(w)
if ~strcmp(w.m,'affine')
	error('Dataset conversion only defined for affine mappings')
end
a = dataset(w.d(1:w.k,:),[],w.l,[],[],-w.p);
return
