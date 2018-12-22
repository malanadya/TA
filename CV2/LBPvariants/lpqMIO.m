%this is a modified version of the original LPQ code:
%http://www.ee.oulu.fi/mvg/download/lpq/lpq.m

function [h, B] = lpq(T, r, f, rho,t)
% Local Phase Quantization (LPQ)
% [h, B] = lpq(T, r)
% where 
%   T = input image
%   r = radius of the operator (default = 3)
%   h = resulting lpq histogram
%   B = labeled image
%   t = is used for calculating the ternary code

if nargin==1
    r=3; %default radius
    f=1;
    rho=0.95;
    t=0;
end

if nargin==2
    f=1;
    rho=0.95;
    t=0;
end

T=double(T);

x=-r:r;
n=length(x);


[xp,yp]=meshgrid(1:n,1:n);
pp=[xp(:) yp(:)];
dd=dist(pp,pp');
C=rho.^dd;

w0=(x*0+1);%maschera intorno da usare x calcolo locale
w1=exp(-2*pi*j*x*f/n);
w2=conj(w1);

q1=w0.'*w1;
q2=w1.'*w0;
q3=w1.'*w1;
q4=w1.'*w2;

u1=real(q1); u2=imag(q1);
u3=real(q2); u4=imag(q2);
u5=real(q3); u6=imag(q3);
u7=real(q4); u8=imag(q4);

M=[u1(:)';u2(:)';u3(:)';u4(:)';u5(:)';u6(:)';u7(:)';u8(:)'];
D=M*C*M';
[U,S,V]=svd(D);


Qa=conv2(conv2(T,w0.','same'),w1,'same');
Qb=conv2(conv2(T,w1.','same'),w0,'same');
Qc=conv2(conv2(T,w1.','same'),w1,'same');
Qd=conv2(conv2(T,w1.','same'),w2,'same');

Fa=real(Qa); Ga=imag(Qa);
Fb=real(Qb); Gb=imag(Qb);
Fc=real(Qc); Gc=imag(Qc);
Fd=real(Qd); Gd=imag(Qd);
F=[Fa(:) Ga(:) Fb(:) Gb(:) Fc(:) Gc(:) Fd(:) Gd(:)];
G=(V'*F');

if length(t)==1 & t==0
    B=(G(1,:)>=t)+(G(2,:)>=t)*2+(G(3,:)>=t)*4+(G(4,:)>=t)*8+(G(5,:)>=t)*16+(G(6,:)>=t)*32+(G(7,:)>=t)*64+(G(8,:)>=t)*128;
    B=reshape(B,size(Fa,1),size(Fa,2));
    h=hist(B(:),0:255);
    h=h/sum(h);
end

if length(t)==1 & t~=0
    t=t*std(G');
    
    B=(G(1,:)>=t(1))+(G(2,:)>=t(2))*2+(G(3,:)>=t(3))*4+(G(4,:)>=t(4))*8+(G(5,:)>=t(5))*16+(G(6,:)>=t(6))*32+(G(7,:)>=t(7))*64+(G(8,:)>=t(8))*128;
    B=reshape(B,size(Fa,1),size(Fa,2));
    h=hist(B(:),0:255);
    h=h/sum(h);
    
    B=(G(1,:)<=-t(1))+(G(2,:)<=-t(2))*2+(G(3,:)<=-t(3))*4+(G(4,:)<=-t(4))*8+(G(5,:)<=-t(5))*16+(G(6,:)<=-t(6))*32+(G(7,:)<=-t(7))*64+(G(8,:)<=-t(8))*128;
    B=reshape(B,size(Fa,1),size(Fa,2));
    h1=hist(B(:),0:255);
    h=[h h1/sum(h1)];
end

if length(t)==2 
    tt=t;clear t
    t(:,1)=tt(1)*std(G');
    t(:,2)=tt(2)*std(G');
    
    B=(G(1,:)>=t(1,2))+(G(2,:)>=t(2,2))*2+(G(3,:)>=t(3,2))*4+(G(4,:)>=t(4,2))*8+(G(5,:)>=t(5,2))*16+(G(6,:)>=t(6,2))*32+(G(7,:)>=t(7,2))*64+(G(8,:)>=t(8,2))*128;
    B=reshape(B,size(Fa,1),size(Fa,2));
    h=hist(B(:),0:255);
    h=h/sum(h);
    
    B=(G(1,:)<=-t(1,2))+(G(2,:)<=-t(2,2))*2+(G(3,:)<=-t(3,2))*4+(G(4,:)<=-t(4,2))*8+(G(5,:)<=-t(5,2))*16+(G(6,:)<=-t(6,2))*32+(G(7,:)<=-t(7,2))*64+(G(8,:)<=-t(8,2))*128;
    B=reshape(B,size(Fa,1),size(Fa,2));
    h1=hist(B(:),0:255);
    h=[h h1/sum(h1)];
    
    B=(G(1,:)>=t(1,1)& G(1,:)<t(1,2))+(G(2,:)>=t(2,1)& G(2,:)<t(2,2))*2+(G(3,:)>=t(3,1)& G(3,:)<t(3,2))*4+(G(4,:)>=t(4,1)& G(4,:)<t(4,2))*8+(G(5,:)>=t(5,1)& G(5,:)<t(5,2))*16+(G(6,:)>=t(6,1)& G(6,:)<t(6,2))*32+(G(7,:)>=t(7,1)& G(7,:)<t(7,2))*64+(G(8,:)>=t(8,1)& G(8,:)<t(8,2))*128;
    B=reshape(B,size(Fa,1),size(Fa,2));
    h1=hist(B(:),0:255);
    h=[h h1/sum(h1)];
    
    B=(G(1,:)>=-t(1,2)& G(1,:)<-t(1,1))+(G(2,:)>=-t(2,2)& G(2,:)<-t(2,1))*2+(G(3,:)>=-t(3,2)& G(3,:)<-t(3,1))*4+(G(4,:)>=-t(4,2)& G(4,:)<-t(4,1))*8+(G(5,:)>=-t(5,2)& G(5,:)<-t(5,1))*16+(G(6,:)>=-t(6,2)& G(6,:)<-t(6,1))*32+(G(7,:)>=-t(7,2)& G(7,:)<-t(7,1))*64+(G(8,:)>=-t(8,2)& G(8,:)<-t(8,1))*128;
    B=reshape(B,size(Fa,1),size(Fa,2));
    h1=hist(B(:),0:255);
    h=[h h1/sum(h1)];
end
h=single(h);

























