function hh=plotbands(xmarks)
% PLOTBANDS  Add coloured bands below plot
%   PLOTBANDS(XMARKS) add coloured vertical bands below the current
%   plot. The bands are delimited by the entries of the vector
%   XMARKS.

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

h=gca ;
set(gca,'Color','none') ;
xlim=get(gca,'xlim') ;
ylim=get(gca,'ylim') ;

colors=get(h,'ColorOrder') ;
colors=0.2*colors + 0.8*ones(size(colors)) ;
ncolors=size(colors,1) ;

K=length(xmarks)-1 ;
x = zeros(4,K) ;
y = zeros(4,K) ;
c = zeros(1,K,3) ;
for k=1:K
	xb=min(max(xmarks(k),  xlim(1)),xlim(2)) ;
	xe=min(max(xmarks(k+1),xlim(1)),xlim(2)) ;		
	yb=ylim(1) ;
	ye=ylim(2) ;
	x(:,k) = [xb;xe;xe;xb] ;
	y(:,k) = [yb;yb;ye;ye] ;
	c(1,k,:) = colors(mod(k,ncolors)+1,:) ;		
end

hh=patch(x,y,c,'LineStyle', 'none') ;
children = get(h,'Children') ;
set(h,'Children',circshift(children,1)) ;
