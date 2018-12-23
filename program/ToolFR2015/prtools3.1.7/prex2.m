%PREX2 PRTOOLS example, plot learning curves of classifiers
help prex2
pause(1)
echo on
						% set desired learning sizes
learnsize = [3 5 10 15 20 30];
						% Generate Highleyman's classes
A = gendath(100,100); 
						% avarage error over 10 repetitions
						% testset is complement of training set
e1 = cleval(ldc,A,learnsize,10);
figure(1); hold off;
plot(learnsize,e1(1,:),'-'); 
axis([0 30 0 0.3]); hold on; drawnow;
e2 = cleval(qdc,A,learnsize,10);
plot(learnsize,e2(1,:),'-.'); drawnow;
e3 = cleval(knnc([],1),A,learnsize,10);
plot(learnsize,e3(1,:),'--'); drawnow;
e4 = cleval(treec,A,learnsize,10);
plot(learnsize,e4(1,:),':');  drawnow;
legend('Linear','Quadratic','1-NN','DecTree');
xlabel('Sample Size')
ylabel('Error');
echo off
