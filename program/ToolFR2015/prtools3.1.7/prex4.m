%PREX4 PRTOOLS example of classifier combining
help prex4
echo on

A = gendatd(100,100,10);
[B,C] = gendat(A,20);

wkl = klm(B,0.95);					% find KL mapping input space
bkl = B*wkl;						% map training set
vkl = ldc(bkl);						% find classifier in mapped space
w1 = wkl*vkl;						% combine map and classifier 
									% (operates in original space)
testd(C*w1)							% test 

wfn = featself(B,'NN',3); 			% find feature selection mapping
bfn = B*wfn;						% map training set
vfn = ldc(bfn);						% find classifier in mapped space
w2 = wfn*vfn;						% combine
testd(C*w2)							% test

wfm = featself(B,ldc,3); 			% find second feature set
bfm = B*wfm;						% map training set
vfm = ldc(bfm);						% find classifier in mapped space
w3 = wfm*vfm;						% combine
testd(C*w3)							% test

w4 = ldc(B);						% find classifier in input space
testd(C*w4)							% test
w5 = knnc(B,1);						% another classifier in input space
testd(C*w5)							% test

wall = [w1,w2,w3,w4,w5];			% parallel classifier set 
testd(C*prodc(wall))				% test product rule
testd(C*meanc(wall))				% test mean rule
testd(C*medianc(wall))				% test median rule
testd(C*maxc(wall))					% test maximum rule again
testd(C*minc(wall))					% test minimum rule
testd(C*majorc(wall))				% test majority voting

echo off
