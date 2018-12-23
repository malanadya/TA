%PREX1 PRTOOLS example of classifiers and scatter plot
help prex1
pause(1)
echo on
A = gendath(100,100); % Generate Highleyman's classes
						% Training set c (20 objects / class)
						% Test set d (80 objects / class)
[C,D] = gendat(A,20);
						% Compute classifiers
w1 = ldc(C);						% linear
w2 = qdc(C);						% quadratic
w3 = parzenc(C);						% Parzen
w4 = lmnc(C,3);% Neural Net
						% Compute and display errors
disp([testd(D*w1),testd(D*w2),testd(D*w3),testd(D*w4)]);
	  					% Plot data and classifiers
figure(1);
hold off;
scatterd(A); drawnow;
plotd(w1,'-'); drawnow;
plotd(w2,'-.'); drawnow;
plotd(w3,'--'); drawnow;
plotd(w4,':'); drawnow;
echo off
