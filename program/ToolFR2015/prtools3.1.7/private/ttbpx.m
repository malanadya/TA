function [w,i,tr]=ttbpx(w,f,n,p,t,tp,fid)
% TTBPX Train multilayer feed-forward network w/fast backpropagation.
% This is an adapted version of tbpx to be called by bpxnncml.m
% Results are not displayed.
% Weights, biases (w) and activation functions (f) can be created by 
% initbp or initbpnw (using Nguyen-Widrow initialization).
%	
%	[W,TE,TR] = TTBPX(W,F,N,P,T,TP,FID)
%	  W  - weights and biases (a reshaped row vector).
%	  F  - a row vector with each element of the vector
%	       specifying the activation function per layer
%	       of the feed-forward network.  
%	  N  - a row vector with the elements of the vector 
%	       specifying the number of hidden neurons per hidden
%	       layer. So the number of elements of the vector
%	       indicates the number of hidden layers.
%	  P  - RxQ matrix of input vectors.
%	  T  - SxQ matrix of target vectors.
%	  TP - Training parameters (optional).
%    FID- File pointer for progress report
%	Returns:
%	  W  - new weights and new biases (a reshaped row vector).
%	  TE - the actual number of epochs trained.
%	  TR - training record: [row of errors]
%	
%	Training parameters are:
%	  TP(1) - Epochs between updating display, default = 25.
%	  TP(2) - Maximum number of epochs to train, default = 1000.
%	  TP(3) - Sum-squared error goal, default = 0.02.
%	  TP(4) - Learning rate, 0.01.
%	  TP(5) - Learning rate increase, default = 1.05.
%	  TP(6) - Learning rate decrease, default = 0.7.
%	  TP(7) - Momentum constant, default = 0.9.
%	  TP(8) - Maximum error ratio, default = 1.04.
%	Missing parameters and NaN's are replaced with defaults.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright (c) 1992-94 by the MathWorks, Inc.
% $Revision: 1.1 $  $Date: 1994/01/11 16:29:44 $
% Multi-layer adaptations (tpbx.m) by : W.L.Li, april 1996
%                              abd by : R.P.W. Duin, august 1997

if nargin < 5,error('Not enough arguments.'),end

% TRAINING PARAMETERS
if nargin == 5, tp = []; fid = 0; end
tp = nndef(tp,[25 1000 0.02 0.01 1.05 0.7 0.9 1.04]);
df = tp(1);
me = tp(2);
eg = tp(3);
lr = tp(4);
im = tp(5);
dm = tp(6);
mc = tp(7);
er = tp(8);
% SOME DEFINITIONS
nl=length(n)+1;		% nl is the number of layers.
[in,ntp]=size(p);	% in is the number of input neurons, 
			% ntp is the number of training patterns.
[out,ntp]=size(t);	% out is the number of output neurons.
n = [n,out];
% UNPACKING W TO WEIGHT MATRICES AND BIAS VECTORS
N = [in,n];
	% unpack w to w1,w2, w3, ... , b1,b2, b3, ... etc.
for c=1:nl
	s = feval(eval(['deblank(f(',int2str(c),',:))']),'delta');
	eval(['df',int2str(c),'=s;'])
	eval(['w',int2str(c),'=reshape(w(1:(N(c)+1)*n(c)),N(c)+1,n(c));'])
	eval('w(1:(N(c)+1)*n(c))=[];')
	eval(['w',int2str(c),'=w',int2str(c),setstr(39),';'])
	eval(['b',int2str(c),'=w',int2str(c),'(:,N(c)+1);'])
	eval(['w',int2str(c),'(:,N(c)+1)=[];'])
end
	% note that by now w has been deleted, because of the reshape method

	% calculate dw1, db1, dw2, db2, ... etc.
for c=1:nl
	eval(['dw',int2str(c),'=w',int2str(c),'*0;'])
	eval(['db',int2str(c),'=b',int2str(c),'*0;'])
end
MC = 0;

a1 = feval(deblank(f(1,:)),w1*p,b1);
for c=2:nl
	am=['a' int2str(c-1)];
	w=['w' int2str(c)];
	b=['b' int2str(c)];
	eval(['a',int2str(c),'=feval(deblank(f(',int2str(c),',:)),eval(w)*eval(am),eval(b));']);
end
	
	% calculate error e and SSE
anp=['a' int2str(nl)];
e=t-eval(anp);
SSE = sumsqr(e);

% TRAINING RECORD
tr = zeros(2,me+1);
tr(1:2,1) = [SSE; lr];

% BACKPROPAGATION PHASE
anp=['a' int2str(nl)];
df=['df' int2str(nl)];
eval(['d',int2str(nl),'=feval(eval(df),eval(anp),e);']);
for c=nl-1:-1:1
	a=['a' int2str(c)];
	df=['df' int2str(c)];
	wp=['w' int2str(c+1)];
	dp=['d' int2str(c+1)];
	eval(['d',int2str(c),'=feval(eval(df),eval(a),eval(dp),eval(wp));']);
end

for i=1:me

  % CHECK PHASE
	if SSE < eg, i=i-1; break, end
  % LEARNING PHASE
	[dw1,db1] = learnbpm(p,d1,lr,MC,dw1,db1);
	for c=2:nl
		am=['a' int2str(c-1)];
		d=['d' int2str(c)];
		dw=['dw' int2str(c)];
		db=['db' int2str(c)];
		eval(['[dw',int2str(c),',','db',int2str(c), ...
		']=learnbpm(eval(am),eval(d),lr,MC,eval(dw),eval(db));']);
	end
	MC = mc;
	for c=1:nl
		eval(['new_w',int2str(c),'=w',int2str(c),'+dw',int2str(c),';']);
		eval(['new_b',int2str(c),'=b',int2str(c),'+db',int2str(c),';']);
	end
  % PRESENTATION PHASE
	new_a1 = feval(deblank(f(1,:)),new_w1*p,new_b1);
	for c=2:nl
		am=['new_a' int2str(c-1)];
		w=['new_w' int2str(c)];
		b=['new_b' int2str(c)];
		eval(['new_a',int2str(c),'=feval(deblank(f(',int2str(c),',:)),eval(w)*eval(am),eval(b));']);
	end
	anp=['new_a' int2str(nl)];
	new_e=t-eval(anp);
  	new_SSE = sumsqr(new_e);

  % MOMENTUM & ADAPTIVE LEARNING RATE PHASE
  if new_SSE > SSE*er
    	lr = lr * dm;
    	MC = 0;
  else
    	if new_SSE < SSE
        	lr = lr * im;
    	end
	for c=1:nl
		eval(['w',int2str(c),'=new_w',int2str(c),';']);
		eval(['b',int2str(c),'=new_b',int2str(c),';']);
		eval(['a',int2str(c),'=new_a',int2str(c),';']);
	end
   e = new_e; SSE = new_SSE;
  % BACKPROPAGATION PHASE
	anp=['a' int2str(nl)];
	df=['df' int2str(nl)];
	eval(['d',int2str(nl),'=feval(eval(df),eval(anp),e);']);
	for c=nl-1:-1:1
		a=['a' int2str(c)];
		df=['df' int2str(c)];
		wp=['w' int2str(c+1)];
		dp=['d' int2str(c+1)];
		eval(['d',int2str(c),'=feval(eval(df),eval(a),eval(dp),eval(wp));']);
	end
  end

  % TRAINING RECORD
  tr(1:2,i+1) = [SSE; lr];
  if ceil(i/20)*20 == i
%	fprintf(fid,'epochs:%5i  mse: %10.7e  lr: %5.3e\n',i,SSE,lr);
  end
end
% TRAINING RECORD
tr = tr(1:2,1:(i+1));

% RESHAPE WEIGHT MATRICES AND BIAS VECTORS TO A VECTOR
w = [];
for c=1:nl
	ww = eval(['[w',int2str(c),setstr(39),';b',int2str(c),setstr(39),']']);
	w = [w,ww(:)'];
%	w=eval(['[w,reshape([w',int2str(c),setstr(39),';b',int2str(c),setstr(39) ...
%	       ,'],1,(N(c)+1)*n(c))]']);
end
return; 

