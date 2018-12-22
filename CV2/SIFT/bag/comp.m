function comp(database, tree, i, j)
% COMP  Compare images in database
%   COMP(DATABASE, TREE, I, J) browses interactivley the
%   correspondences between image I and J in the database. The
%   function computes the signatures of I and J and sort the signature
%   bins by `matching relevance', with the most relevant first. It
%   then displays the features belonging to those bins, one per
%   time.

go_config ;

sign1 = database(i).sign ;
sign2 = database(j).sign ;

name1 = database(i).name ;
name2 = database(j).name ;

% matching relevance score
sm = double(sign1) + double(sign2) ;
df = abs(double(sign1) - double(sign2)) ;
sc = sm - df ;%sm ./ (df+eps) ;

fprintf('%s\n',name1) ;
fprintf('%s\n',name2) ;

[dr,paths] = sort(-sc) ;

I1 = imread(getimg(name1)) ;
I2 = imread(getimg(name2)) ;
[f1,d1] = getd(name1) ;
[f2,d2] = getd(name2) ;

for k=1:length(paths)
	[sel1,a1] = selm(tree,paths(k),d1) ;
	[sel2,a2] = selm(tree,paths(k),d2) ;
		
	figure(100); clf; 
	subplot(2,2,1) ; 
	imagesc(I1) ;hold on ;
	plotframe(f1(:,sel1)) ;
	
	subplot(2,2,2) ; 
	imagesc(I2) ;hold on ;
	plotframe(f2(:,sel2)) ;
	drawnow;

	subplot(2,2,3) ; imagesc(d1(:,sel1)) ;
	subplot(2,2,4) ; imagesc(d2(:,sel2)) ;

	fprintf('Rel reduction %f\n',sc(paths(k))) ;
	fprintf('Cluster label:\n') ;
	disp(a1) ;
	dr=input('Next...') ;	
end

% --------------------------------------------------------------------
function name = getimg(name)
% --------------------------------------------------------------------
go_config ;
name = strrep(name,pfx_sift,pfx_images) ;
[path,base,ext] = fileparts(name) ;
name = fullfile(path, [base '.jpg']) ;

% --------------------------------------------------------------------
function [f,d] = getd(name)
% --------------------------------------------------------------------
%keyboard
[path,base,ext]=fileparts(name);
namef=fullfile(path,[base,'.key']) ;
named=fullfile(path,[base,'.desc']) ;
f = load(namef)' ;
fd = fopen(named) ;
d = fread(fd,[128 +inf],'uint8=>uint8') ;
fclose(fd) ;

f(3,:) = f(3,:) * 6 ; % sift sigma -> circle radius

% --------------------------------------------------------------------
function [sel,path_asgn] = selm(tree,path,desc)
% --------------------------------------------------------------------
asgn = hikmeanspush(tree,desc) ;

depth     = size(asgn,2) ;
K         = length(tree.sub) ;

%                     depth    pdepth  poff     lsiz
%      ____o____      0 (root) 0       0        1
%     /    |    \
%    o     o     o    1        1       K^0      K
%   /|\   /|\   /|\
%  o o o o o o o o o  2        2       K^0+K^1  K^2

% find path depth
orig = path ;
path = path - 1 ; % make 0 based
tmp = path ;
lev_size = 1 ;
for d=1:depth
	lev_size = lev_size *  K ;
	if( path < lev_size )
		% found; break here
		break ;
	end
	path = path - lev_size ;
end
path_depth = d ;

% now d is the path depth; find path_asgn
path_asgn = zeros(path_depth,1) ;
for d=1:path_depth
	den = K^(path_depth-d) ;
	path_asgn(d) = floor(path / den)  ;
	path         = path - den*path_asgn(d) ;
end
path_asgn = path_asgn + 1 ;

% sanity check
if 0
	orig - max(find(signdata(K,path_depth,uint32(path_asgn))))
end

n = size(asgn,2) ;
sel = find(all(repmat(path_asgn,1,n)==asgn(1:path_depth,:),1)) ;
