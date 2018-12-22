% Print pictures

mkdir(pwd,'results') ;
figure(4002) ; print -depsc results/signatures.ps
figure(4003) ; print -depsc results/distances.ps
figure(5000) ; print -depsc results/classification.ps
