%GENLAB Generate labels for classes
% 
% 	labels = genlab(n,lablist)
% 
% Generates a set of labels as defined by the labellist lablist. n 
% is a vector. The first n(i) labels get the value lablist(i,:). If 
% lablist is omitted labels as '1', '2', ... are used.
% 
% Labels can be used to construct a labelled dataset.
% 
% See also datasets, datatset

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function labels = genlab(n,lablist)
labels = [];
if nargin == 1
   lab = 1;
   for i = 1:length(n)
		labels = [labels; ones(n(i),1)*lab];
	   lab = lab+1;
   end
else
   [m,s] = size(lablist);
   if m ~= length(n)
      error('Wrong number of labels')
   end
   for i = 1:length(n)
       labels = [labels; ones(n(i),1)*lablist(i,:)];
   end
	if isstr(lablist), labels=setstr(labels); end
end
return
