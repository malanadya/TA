%CLEVAL Classifier evaluation (learning curve), bootstrap version
% 
% 	[e,s] = cleval(classf,A,learnsizes,n,T,print)
% 
% Generates at random for all class sizes of the training set 
% defined in the vector 'learnsizes' training sets out of the 
% dataset A, uses these for training the untrained classifier 
% classf. All objects in A are used for testing. This is repeated
% n times. 
% The mean erors are stored in e. The observed standard deviations 
% are stored in s.
% 
% The training set generation is done "with replacement", and such 
% that for each run the larger training sets include the smaller 
% ones.
% 
% See also clevalb, clevalt, testd, mappings, datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [error,sd] = clevalb(classf,a,learnsizes,n,print)
if nargin < 5, print = 0; end;
if nargin < 4, n = 1; end;
if nargin < 3, learnsizes = [2,3,5,7,10,15,20,30,50,70,100]; end;
if ~isa(classf,'mapping'), error('First parameter should be mapping'); end
[nlab,lablist,m,k,c] = dataset(a);
learnsizes = learnsizes(:)';
mc = sum(expandd(nlab,c));
if max(learnsizes) > min(mc)
	error('Learnsize larger than data size');
end
e = zeros(n,length(learnsizes));
for i = 1:n
	JR = zeros(c,max(learnsizes));
	for p = 1:c
		JC = find(nlab==p);
		R = ceil(rand(1,max(learnsizes))*length(JC));
		JR(p,:) = JC(R)';
	end
	jj = 0;
	for j = learnsizes
		jj = jj + 1;
		J = [];
    	for p = 1:c
			J = [J;JR(p,1:j)']; 
   	end; 
		W = a(J,:)*classf;
  		e(i,jj) = testd(a,W);
		if print, fprintf('.'); end
	end
end
if print, fprintf('\n'); end
error = mean(e);
if n == 1
	sd = zeros(size(error));
else
	sd = std(e);
end
return
