%SET Set mapping parameters
%
%	W = set(W,name,value)
%
% Sets the parameter of the given name (as string) of the mapping W to value.
% No error checking is done. If this is desired, use the mapping command.
%
% List of parameter names:
%
%  m name of routine used for learning or testing
%  d weights defining the mapping.
%  l output labels for the outputs ('class names')
%    of the mapping.
%  k number of inputs of the mapping.
%  c number of outputs of the mapping.
%  v output multiplication factor(s)
%  p parameter vector describing the  mapping structure 
%  s desired output conversion
%  r reject value
%  t description 
%
% See mappings, mapping for more information

function w = set(w,name,v)
if ~isa(w,'mapping')
	error('mapping expected')
end

switch name

case 'm'
	w.m = v;
case 'd'
	w.d = v;
case 'l'
	w.l = v;
case 'k'
	w.k = v;
case 'c'
	w.c = v;
case 'v'
	w.v = v;
case 'p'
	w.p = v;
case 's'
	w.s = v;
case 'r'
	w.r = v;
case 't'
	w.t = v;
otherwise
	error('Unknown parameter name found')
end
	
