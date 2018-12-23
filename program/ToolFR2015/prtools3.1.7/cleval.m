%CLEVAL Classifier evaluation (learning curve)
% 
% 	[e,s] = cleval(classf,A,learnsizes,n,T,print)
% 
% Generates at random for all class sizes of the training set 
% defined in the vector 'learnsizes' training sets out of the 
% dataset A, uses these for training the untrained classifier 
% classf. The result is tested by the test dataset T, or, if not
% given, by all unused objects in A. This is  repeated n times.
% The mean erors are stored in e. The observed standard deviations
% are stored in s.
% 
% The learning set generation is such that for each run the larger 
% training sets include the smaller ones.
% 
% This function uses the rand random generator and thereby 
% reproduces if its seed is reset.
% 
% See also clevalb, testd, mappings, datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [err,sd] = cleval(classf,a,learnsizes,n,T,print)
if nargin < 6, print = 0; end;
if nargin < 5, T = []; end
if nargin < 4, n = 1; end;
if nargin < 3, learnsizes = [2,3,5,7,10,15,20,30,50,70,100]; end;
if ~isa(classf,'mapping'), error('First parameter should be mapping'); end
[nlab,lablist,m,k,c] = dataset(a);
learnsizes = learnsizes(:)';
mc = sum(expandd(nlab,c));
if max(learnsizes) > min(mc)
	error('Learnsize larger than data size');
end
e1 = zeros(n,length(learnsizes));
s = rand('seed');
for i = 1:n
	JR = zeros(c,max(learnsizes));
	for p = 1:c
		JC = find(nlab==p);
		rand('seed',s);
		JD = JC(randperm(mc(p)));
		s = rand('seed');
		JR(p,:) = JD(1:max(learnsizes))';
	end
	jj = 0;
	for j = learnsizes
		jj = jj + 1;
		J = [];
		for p = 1:c
			J = [J;JR(p,1:j)']; 
		end;
		W = a(J,:)*classf;
		if isempty(T)
  			JT = ones(m,1);
			JT(J) = zeros(size(J));
			JT = find(JT);a(JT,:);
			e1(i,jj) = testd(a(JT,:),W);
		else
			e1(i,jj) = testd(T,W);
		end
		if print, fprintf('.'); end;
	end
end
if print, fprintf('\n'); end 
err = mean(e1,1);
if n == 1
	sd = zeros(size(err));
else
	sd = std(e1);
end
return
