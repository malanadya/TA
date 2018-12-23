%PRDATA Read data files
% 
% 	A = prdata('file')
% 
% Reads PR data into the dataset A. The first word of each line is 
% interpreted as label data. Each line is stored row-wise and 
% interpreted as the feature values of a single object.
% 
% 	A = prdata('file',0)
% 
% No labels assumed. The first word of each line is now interpreted 
% as data.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = prdata(file,labels)
if nargin < 2, labels = 1; end
fid = fopen(file);
if fid < 0
	error('Error in opening file')
end
s = fread(fid,inf,'uchar');
if computer=='MAC2', ss=13; else ss=10; end
i = find(s==ss);
n = length(sscanf(setstr(s(1:i(1))),'%e'));
fseek(fid,0,'bof');
[a,num] = fscanf(fid,'%e',inf);
a = reshape(a,n,num/n)';
if labels
	lab=a(:,1);
	a(:,1)=[];
	a = dataset(a,lab);
else
	a = dataset(a);
end
return
