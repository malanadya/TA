% Perform classification using Nister-like method

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

if exist('tree') ~= 1
	load(pfx_tree) ;
end

N     = length(database) ;         % n of images in database
L     = size(database(1).sign,1) ; % length of a signature
cats  = unique([database.cat_id]); % list of categories
ncats = length(cats) ;

if ~exist('sign0')
	% first Q images are training, rest is testing
	% for each test image, we retrieve the closest training
	sign0=uint8(zeros(L,ncats*class_ntrain)) ;
	b=1 ;
	for c=cats
		e=b+class_ntrain-1 ;
		sel = find([database.cat_id]==c & [database.is_train]) ;	
		sign0(:,b:e) = [database(sel).sign] ;
		b=e+1 ;
	end
end

% now classifiy the rest
if ~exist('confusion')
  confusion=zeros(ncats,ncats) ;
  for c=cats
    sel = find([database.cat_id]==c & ~ [database.is_train]) ;
    for k=sel
      sign = database(k).sign ;
      d = signdist(sign0,sign) ;
      [d,perm]=sort(d);		
      vote_for = floor( (perm(1:class_nvotes)-1) / class_ntrain) + 1 ;
      votes = binsum(zeros(1,ncats), ones(1,class_nvotes), vote_for) ;
      [drop,best] = max(votes) ;
      database(k).estim_cat = best ;
      %if(c==3 & best ~= 3), keyboard ; end
      confusion(c,best) = confusion(c,best) + 1 ;
    end
		fprintf('Done with category %d of %d.\n',c,ncats) ;
  end
  
  for c=cats
    confusion(c,:) = confusion(c,:) / sum(confusion(c,:)) ;
  end
	
end
  
% get category names
if ~exist('catnames')
  for c=cats
    sel=find([database.cat_id]==c) ;
    name=database(sel(1)).name ;
    [path,name]=fileparts(name) ;
    [path,cname]=fileparts(path) ;
    catnames{c}=cname ;
  end
end

% plots
figure(5000) ; clf ;
subplot(1,2,1) ; imagesc(confusion) ; 
axis image ;
xlabel('estim. category') ;
ylabel('true category') ;
title('Confusion matrix') ;

plot_full_labels = 1 ;
if plot_full_labels
	set(gca,'XTick',1:ncats,'XTickLabel',catnames) ; h=xtickrot(90) ;set(h,'Interpreter','none');
	set(gca,'YTick',1:ncats,'YTickLabel',catnames)  ;
else
	axis off;
end
	

subplot(1,2,2) ; bar3(confusion') ;
ylabel('estim. category') ;
xlabel('ture category') ;
title('Confusion matrix') ;

if plot_full_labels
	set(gca,'XTick',1:ncats,'XTickLabel',catnames)  ; h=xtickrot(-45) ;set(h,'Interpreter','none');
	set(gca,'YTick',1:ncats,'YTickLabel',catnames)  ;
else
	axis off; 
end

	
save(pfx_classifier, 'sign0', 'confusion', 'database') ;
