%PARZENML Optimum smoothing parameter in Parzen density estimation.
% 
% 	h = parzenml(A)
% 
% Maximum likelihood estimation for the smoothing parameter in the 
% Parzen denstity estimation of the data in A. A leave-one out 
% maximum likelihood estimation is used. If called by
% 
% 	[h,ex] = parzenml(A,ex)
% 
% a speed up is reached in case of multiple calls.
% 
% See also mappings, datasets, parzenc, testp

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [h,ex] = parzenml(A,ex)
[n,k] = size(A);
if nargin == 1, ex = 0; end
if length(ex) ~= 10001
	ex = exp(-[0:1e-3:1e1]);
end

% Note that this routine is purposely written with loops
% in order to allow for larger data sizes.
oa = ones(n,1); za = zeros(1,n);
E = za;
for i = 1:n
	D = +distm(A(i,:),A); D(i) = inf;
	E(i) = min(D);
end	
h1 = sqrt(max(E));
FF = zeros(1,n);
FU = zeros(1,n);
for i=1:n
	D = distm(A(i,:),A); D(i) = 1e70;
	Y = (500/(h1*h1))*(D-E);
	IY = find(Y<10000);
	P = za;
	P(IY) = ex(round(Y(IY))+1);
	FU(i) = 1/sum(P);
	FF(i) = D*P';
end 
F1 = (FF*FU')./(h1*h1) - n*k;
%fprintf('h = %5.3f   F = %8.3e \n',h1,F1);
if abs(F1) < 1e-70 
	h = h1;
	return;
end
a1 = (F1+n*k)*h1*h1;
h2 = sqrt(a1/(n*k));
for i=1:n
	D = distm(A(i,:),A); D(i) = 1e70;
	Y = (500/(h2*h2))*(D-E);
	IY = find(Y<10000);
	P = za;
	P(IY) = ex(round(Y(IY))+1);  
	FU(i) = 1/(sum(P)+ex(end));   % scalar
	FF(i) = D*P';
end 
F2 = FF*FU'./(h2*h2) - n*k;
%fprintf('h = %5.3f   F = %8.3e \n',h2,F2);
if (abs(F2) < 1e-70) | (abs(1e0-h1/h2) < 1e-6) 
	h = h2;
	return
end
while abs(1e0-F2/F1) > 1e-4 & abs(1e0-h2/h1) > 1e-3 & abs(F2) > 1e-70
	h3 = (h1*h1*h2*h2)*(F2-F1)/(F2*h2*h2-F1*h1*h1);
	if h3 < 0
		h3 = sqrt((F2+n*k)*h2*h2/(n*k));
	else
		h3 = sqrt(h3);
	end
	for i=1:n
		D = distm(A(i,:),A); D(i) = 1e70;
		Y = (500/(h3*h3))*(D-E);
		IY = find(Y<10000);
		P = za;
		P(IY) = ex(round(Y(IY))+1);
		if sum(P) == 0, FU(i) = realmax;
		else FU(i) = 1/sum(P);  end  % scalar
		FF(i) = D*P';
	end 
	F3 = FF*FU'./(h3*h3) - n*k;
%	fprintf('h = %5.3f   F = %8.3e \n',h3,F3);
	F1 = F2;
	F2 = F3;
	h1 = h2;
	h2 = h3;
end
h = h2;
return
