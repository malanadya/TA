%DATAIM Image operation on dataset images
%
%	B = dataim(A,'image-command',par1,par2,....)
%
% Reshapes all datavectors in the dataset A into images (if defined so),
% performs the command
%
%    image-out = image-command(image-in,par1,par2,....)
%
% on these images and stores the result back into the dataset B.
%
% See also datasets, im2obj, im2feat, datgauss, datfilt

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function b = dataim(a,command,varargin)
[nlab,lablist,m,k,c,prob,featlist] = dataset(a);
im = data2im(a);
[imheight,imwidth,nim] = size(im);
out = feval(command,im(:,:,1),varargin{:});
[no,mo] = size(out);
if isfeatim(a) & any([no,mo] ~= [imheight,imwidth])
	error('Image size may not change')
end
jm = zeros(no,mo,nim);
jm(:,:,1) = out;
for i=2:nim
	jm(:,:,i) = feval(command,im(:,:,i),varargin{:});
end
if isfeatim(a)
	b = dataset(im2feat(jm),[],featlist,prob,lablist);
else
	b = dataset(im2obj(jm),getlab(a),[],prob,lablist);
end
b
