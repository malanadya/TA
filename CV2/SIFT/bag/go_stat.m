% Scan the database to collect statistics

% AUTORIGHTS
% Copyright (C) 2006 Regents of the University of California
% All rights reserved
% 
% Written by Andrea Vedaldi (UCLA VisionLab).
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in the
%       documentation and/or other materials provided with the distribution.
%     * Neither the name of the University of California, Berkeley nor the
%       names of its contributors may be used to endorse or promote products
%       derived from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
% EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

go_config ;
load(pfx_tree) ;
N = length(database) ;

% how many images per category
cats=unique([database.cat_id]) ;
ncats=length(cats);
if ~exist('nim_per_cat')
	for c=1:ncats
		nim_per_cat(c) = ...
				numel(find([database.cat_id]==c)) ;
	end
end

% how many features
nfeats = [database.nfeats] ;

% size of the images
if ~exist('imsize')
	imsize = zeros(1,N) ;
	for k=1:N
		
		% reconsturct image name from SIFT file name
		sift_name      = database(k).name ;
		[path,name]    = fileparts(sift_name) ;
		[path,catname] = fileparts(path) ;
		image_name     = fullfile(pfx_images, catname, [name '.jpg']) ;
		
		info = imfinfo(image_name) ;
		imsize(k) = sqrt(info.Width * info.Height);
	end
end

xmarks = cumsum([1 nim_per_cat]) ;
figure(4000) ; clf ; 
subplot(2,2,1) ; 
plot(nfeats) ; plotbands(xmarks) ;
title('Number of features for each image') ;
subplot(2,2,2) ;
plot(imsize) ; plotbands(xmarks) ;
title('Image size (square diagonal)') ;
subplot(2,2,3) ; plotbands(xmarks) ;
plot(nfeats./(imsize).^2) ; plotbands(xmarks) ;
title('Number of features  per pixel') ;


figure(4001) ; clf ;
for c=1:ncats
	sel=find([database.cat_id]==c) ;
	tightsubplot(ncats,c,'Spacing',0.05) ;
	plot([database(:,sel(1:4)).sign]) ;
	title(sprintf('Signatures of images in category %d',...
								c)) ;
	set(gca,'YLim',[0 70]);
end

% --------------------------------------------------------------------
%                                                  Database signatures
% --------------------------------------------------------------------

% get category names
for c=cats
  sel=find([database.cat_id]==c) ;
  name=database(sel(1)).name ;
  [path,name]=fileparts(name) ;
  [path,cname]=fileparts(path) ;
  catnames{c}=cname ;
end


figure(4002) ; clf ;
s = [database.sign] ;
L = size(s,1) ;
idx = 1:size(s,2) ;
s = s(:,1:stat_downsample:end);
idx = idx(1:stat_downsample:end) ;
imagesc(idx,1:L,log(double(s)+1)) ;
xlabel('image number')
ylabel('tree node number') ;
title('Signatures') ;

% --------------------------------------------------------------------
%                                             Database inter distances
% --------------------------------------------------------------------
figure(4003) ; clf ;

if ~exist('sdist')
	sdist = double(signdist(s,s)) ;
	sdist = sdist+sdist' ;
end

h=imagesc(idx,idx,sdist) ; 
axis equal ; axis tight;
hold on ;
for k=1:length(xmarks)
	line([xmarks(k) xmarks(k)], get(gca,'YLim'),'LineWidth',4,'Color','g') ; 
	line(get(gca,'XLim'),[xmarks(k) xmarks(k)], 'LineWidth',4,'Color','g') ; 
end

title('Signature distances') ;

set(gca,'XTick',xmarks,'XTickLabel',catnames)  ;
set(gca,'YTick',xmarks,'YTickLabel',catnames)  ;

h=xtickrot(25) ;set(h,'Interpreter','none');



