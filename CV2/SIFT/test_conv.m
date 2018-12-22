figure(101) ; clf ;
I = checkerboard ;
sigmar= logspace(log10(1), log10(20)) ;
J = imsmooth(I,sigmar(1)) ;
for t=2:length(sigmar)
  dsigma = sqrt(sigmar(t)^2 - sigmar(t-1)^2) ;
  J = imsmooth(J,dsigma) ; 
  K = imsmooth(I,sigmar(t)) ;
  tightsubplot(length(sigmar),t) ;
  plot([J(:,end/2) K(:,end/2)]) ; ylim([0 1]) ;
end


