%MAPPING Mapping class constructor
%
%	w = mapping(map,d,lablist,k,c,v,par)
%
% A map/classifier object is constructed from:
% d       size (any), a set of weights defining the mapping
% lablist size [c,n], defines the labels for the outputs ('classes')
%                     of the mapping, either in string or in numbers
%                     c is the number of classes. At least two labels
%                     should be supplied.
% map                 type or name of routine used for learning or testing
% k                   number of inputs
% c                   number of outputs. Note that if c == 1, lablist
%                     should still have two labels, one for each
%                     'direction'
% v  size [c] or size [1] Output multiplication factor, for all
%                     outputs simultaneously or for each output
%                     separately
% par     size (any), parameter vector describing the structure of the
%                     mapping (type dependent)
% classbit    0 | 1   if classc==1 this is a classifier: map by w*sigm*normm
%                     which constructs normalized probabilistic outputs
%
%	w = mapping(w,lablist)
%
% Replaces labellist (i.e. classnames) of a mapping w.
%
%	w = mapping(map,d)
%
% Creates an empty classifier of type stored in string map and parameters
% stored as cells in d.
% Example: w = mapping('treec',{crit,prune}) can later be used in v = a*w
% which is equivalent to v = treec(a,crit,prune). This is in particular
% useful for creating routines that manipulate arbitrary classifiers.
%
% 	[d,lablist,map,k,c,v,par] = mapping(w)
%
% Retrieves the parameters from a mapping w.
%
% See also mappings, getlab, classm, sigm, normm

% w.d = d
% w.l = lablist
% w.t = type % out of date, now []
% w.k = k
% w.c = c
% w.v = v
% w.p = par
% w.m = map
% w.s = classbit
% w.r = rejectvalue

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [w,lablist,map,k,c,v,par] = mapping(map,d,lablist,k,c,v,par)
%disp('mapping')
if isa(map,'mapping')
	if nargin == 2
		[mc,mm] = size(map);
		[nc,nn] = size(d);
		if nc~=mm, error('Labellist has wrong size'); end
		map.l = d;
	elseif nargin > 2
		error('Redefinition of mapping not supported')
	end
	if nargout == 1
		w = map;
	else
		w = map.d;
		lablist = map.l;
		k = map.k;
		c = map.c;
		v = map.v;
		par = map.p;
		classbit = map.s;
		rejectvalue = map.r;
		map = map.m;
	end
	return
end

if nargin < 2
	if ~isa(map,'mapping') & ~isstr(map) & ~isempty(map)
		error('Mapping or mapping definition expected')
	end
	 d = [];
end
[kk,cc] = size(d);
if nargin < 3, lablist = []; end
if nargin < 4, k = 0; end
if nargin < 5, c = 0; end
if nargin < 6, v = 1; end
if nargin < 7, par = []; end
classbit = 0;
rejectvalue = -inf;
if length(v) ~= c & length(v) ~= 1
	error('Output multiplication factor has wrong size');
end

if strcmp(map,'normm') % trick to enable the one to two outputs conversion
	c = -1;          % see also mtimes
end

w.d = d;
w.l = lablist;
w.t = [];
w.c = c;
w.k = k;
w.v = v(:)';
w.p = par;
w.m = map;
w.s = classbit;
w.r = rejectvalue;

w = class(w,'mapping');
superiorto('double')
superiorto('dataset')
%disp('mapping constructed')
return
