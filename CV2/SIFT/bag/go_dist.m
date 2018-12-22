% compute database inter-distances... should see checkerboard here
go_config ;
load(pfx_tree) ;

N=length(database) ;

if ~exist('sdist')
	dist=zeros(N,N) ;
	s = [database.sign] ;
	%s = uint8( (s ~= 0)+1 ) ;
	%s(1:end/2,:) = 0 ;
	sdist = signdist(s,s) ;
end


figure(3001) ; clf ; 
im=sdist;
h=imagesc(im) ;
if(exist('xmarks'))
	hold on ;
	for k=1:length(xmarks)
		line([xmarks(k) xmarks(k)], get(gca,'YLim'),'LineWidth',4,'Color','g') ; 
		line(get(gca,'XLim'),[xmarks(k) xmarks(k)], 'LineWidth',4,'Color','g') ; 
	end
end

	
