%FEATEVAL Evaluation of feature set
% 
% 	J = feateval(A,crit,T)
% 
% Evaluation of features by the criterion crit, using objects in the 
% dataset A. The larger J, the better. Resulting J-values are
% incomparable over the following methods:
% 
% 	crit='maha-s': sum of estimated Mahalanobis distances.
% 	crit='maha-m': minimum of estimated Mahalanobis distances.
% 	crit='eucl-s': sum of squared Euclidean distances.
% 	crit='eucl-m': minimum of squared Euclidean distances.
% 	crit='NN'    : 1-Nearest Neighbour leave-one-out
% 			classification performance (default).
% 			(performance = 1 - error). 
% 
% crit can also be any untrained classifier, e.g. ldc([],1e-6,1e-6). 
% The classification error is used for a performance estimate. If 
% supplied, the dataset T is used for obtaining an unbiased estimate 
% the performance of classifiers trained with the dataset A. If T is 
% not given, the apparent performance on A is used. 
% 
% See also datasets, featselo, featselb, featself, featselp, 
% featselm, featrank

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function J = feateval(a,crit,t)
[nlaba,lablista,ma,k,c] = dataset(a);
if nargin < 2
	crit = 'NN';
end
if nargin < 3, t =[]; end

if ~isempty(t)
	[nlabt,lablistt,mt,kt,c] = dataset(t);
	if kt ~= k
		error('Data sets most have equal numbers of features')
	end
end

if isstr(crit)
	if strcmp(crit,'maha-s') | strcmp(crit,'maha-m') % Mahalanobis distances
		if isempty(t)
			D = distmaha(a);
		else
			[U,G] = meancov(a);
			D = distmaha(t,U,G);
			D = meancov(D);
		end
		if strcmp(crit,'maha-m')
			D = D + realmax*eye(c);
			J = min(min(D));
		else
			J = sum(sum(D))/2; 
		end
   elseif strcmp(crit,'eucl-s') | strcmp(crit,'eucl-m') % Euclidean distances
      U = meancov(a);
      if isempty(t)
         D = distm(U);
      else
         D = distm(t,U);
         D = meancov(D);
      end
      if strcmp(crit,'eucl-m')
         D = D + realmax*eye(c);
         J = min(min(D));
      else
         J = sum(sum(D))/2; 
      end
   elseif strcmp(crit,'NN')	% 1-NN performance
      if isempty(t)
         J = 1 - testk(a,1);
      else
         J = 1 - testk(a,1,t);
      end
   elseif strcmp(crit,'ldc')	% 1-NN performance
       if isempty(t)
           JJ = 1 - testd(a,ldc,5,1);
           J=JJ(1);
       else
      w=ldc(a);
      J = 1 - testd(w*t);
  end
   elseif strcmp(crit,'qdc')	% 1-NN performance
       if isempty(t)
           JJ = 1 - testd(a,qdc,10,5);
           J=JJ(1);
       else
      w=qdc(a);
      J = 1 - testd(w*t);
  end
     elseif strcmp(crit,'fisherc')	% 1-NN performance
       if isempty(t)
           JJ = 1 - testd(a,fisherc,5,1);
           J=JJ(1);
       else
      w=fisherc(a,'multi');
      J = 1 - testd(w*t);
  end
   elseif strcmp(crit,'parzenc')	% 1-NN performance
      w=parzenc(a);
      J = 1 - testd(w*t);
   elseif strcmp(crit,'udc')	% 1-NN performance
      w=udc(a);
      J = 1 - testd(w*t);
   elseif strcmp(crit,'nmc')	% 1-NN performance
      w=nmc(a);
      J = 1 - testd(w*t);
      w=fisherc(a);
      J = 1 - testd(w*t);
   elseif strcmp(crit,'SVM')	% 1-NN performance
       yTR=nlaba;
       TR=+a;
       for i=1:max(yTR)
           y(find(yTR==i))=1;
           y(find(yTR~=i))=2;
           %            model = svmtrain(double([y]'), double([TR]),'-t 0 -c 100');
           %            [PreLabels, accuracy, DecisionValueb] = svmpredict(double([y]'),double([TR]),  model);
           [AlphaY, SVs, Bias, Parameters, nSV, nLabel] = rbfSVC([TR]', double([y]),0.1,1000);
           [ER, DecisionValueb, Ns, ConfMatrix, PreLabels]= SVMTest([TR]', double(y), AlphaY, SVs, Bias, Parameters, nSV, nLabel);

           if DecisionValueb(find(PreLabels==1))<0
               DecisionValueb=DecisionValueb*-1;
           end
           if sum(DecisionValueb(find(PreLabels==2)))>0
               DecisionValueb=DecisionValueb*-1;
           end
           COb(:,i)=DecisionValueb;
       end
       J=CalcoloPerformance(COb',yTR);

    
   end
else
	if isempty(t)
		J = 1 - (a * crit * a * testd);
	else
		J = 1 - (a * crit * t * testd);
	end
end
return
