% We test *IKMEANS* routines

K=3 ;
nleaves=1000 ;

data  = uint8(rand(2,10000)*255) ;
datat = uint8(rand(2,100000)*255) ;

[centers,asgn] = ikmeans(data,K) ;
asgnt = ikmeanspush(datat,centers) ;

figure(1000) ; clf ; hold on ;
hold on ;
colors = get(gca,'ColorOrder') ;
ncolors = size(colors,1) ;
for k=1:10
  sel=find(asgn==k) ;  
  plot(data(1,sel),data(2,sel),'.','Color',colors(mod(k,ncolors)+1,:)) ;
  sel=find(asgnt==k) ;
  plot(datat(1,sel),datat(2,sel),'+','Color',colors(mod(k,ncolors)+1,:)) ;  
end
plot(centers(1,:),centers(2,:),'ro') ;
[tree,asgn]=hikmeans(data,K,nleaves) ;
[asgnt]=hikmeanspush(tree,datat) ;

figure(1001) ; clf ; 
plottree(tree) ;
 
figure(1002) ; clf ; hold on ;
hold on ;
colors = get(gca,'ColorOrder') ;
ncolors = size(colors,1) ;
for k=1:10
  sel=find(asgn(end,:)==k) ;  
  plot(data(1,sel),data(2,sel),'.','Color',colors(mod(k,ncolors)+1,:)) ;
  sel=find(asgnt(end,:)==k) ;
  plot(datat(1,sel),datat(2,sel),'+','Color',colors(mod(k,ncolors)+1,:)) ;  
end
h=plottree(tree) ;
set(h,'LineWidth',4) ;

figure(1003) ; clf ;
sign=signdata(K,tree.depth,asgnt) ;
subplot(2,1,1);plot(sign) ;
subplot(2,1,2);plot(log(double(sign)+eps)) ;


