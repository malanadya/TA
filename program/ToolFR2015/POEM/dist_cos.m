function D = dist_cos(gb1,gb2)
t=double(gb1)*double(gb2)';
m=norm(double(gb1))*norm(double(gb2));
D= -t/m;

% t=gb1-gb2;
% D=sqrt(sum(t.^2));