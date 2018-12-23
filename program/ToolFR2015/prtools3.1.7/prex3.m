%PREX3 PRTOOLS example of multi-class classifier plot
help prex3
echo on
global GRIDSIZE
gs = GRIDSIZE;
GRIDSIZE = 100;
						% generate 2 x 2 normal distributed classes
a = +gendath(20);		% data only
b = +gendath(20);		% data only
A = [a; b + 5];			% shift 2 over [5,5]
lab = genlab([20 20 20 20],[1 2 3 4]');% generate 4-class labels
A = dataset(A,lab);		% construct dataset
hold off; 				% clear figure
scatterd(A,'.'); drawnow;% make scatter plot for right size
w = qdc(A);				% compute normal densities based quadratic classifier
plotd(w,'col'); drawnow;% plot classification regions
hold on;
scatterd(A);			% redraw scatter plot
echo off
GRIDSIZE = gs;
