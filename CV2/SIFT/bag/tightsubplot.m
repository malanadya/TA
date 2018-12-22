function H = tightsubplot(varargin)
% TIGHTSUBPLOT  Tiles axes without wasting space
%   H = TIGHTSUBPLOT(K,P) returns an handle to the P-th axis in a
%   regular grid of K axes. The K axes are numbered from left to right
%   and from top to bottom.  The function operates similarly to
%   SUBPLOT(), but by default it does not put any margin between axes.
%
%   H = TIGHTSUBPLOT(M,N,P) retursn an handle to the P-th axes in a
%   regular subdivision with M rows and N columns.
%
%   The function accepts the following option-value pairs:
%
%   'Spacing' [0]
%     Set extra spacing between axes.  The space is added between the
%     inner or outer boxes, depending on the setting below.
%
%   'Box' ['inner'] (** ONLY >R14 **)
%     If set to 'outer', the function displaces the axes by their
%     outer box, thus protecting title and labels. Unfortunately
%     MATLAB typically picks unnecessarily large insets, so that a bit
%     of space is wasted in this case.  If set to 'inner', the
%     function uses the inner box. This causes the instets of nearby
%     axes to overlap, but it is very space conservative.
%
%   REMARK. While SUBPLOT kills any pre-existing axes that overalps a
%   new one, this function does not.
%
%   See also SUBPLOT().

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

sp=0.0 ;
use_outer=0 ;

% --------------------------------------------------------------------
%                                                      Parse arguments
% --------------------------------------------------------------------
K=varargin{1} ;
p=varargin{2} ;
N = ceil(sqrt(K)) ;
M = ceil(K/N) ;

a=3 ;
NA = length(varargin) ;
if NA > 2
  if isa(varargin{3},'char')
    % Called with K and p
  else
    % Called with M,N and p
    a = 4 ;
    M = K ;
    N = p ;
    p = varargin{3} ;
  end
end

for a=a:2:NA
  switch varargin{a}
    case 'Spacing'
      sp=varargin{a+1} ;
    case 'Box'      
      switch varargin{a+1}
        case 'inner'
          use_outer = 0 ;
        case 'outer'
	if ~strcmp(version('-release'), '14')
          %warning(['Box option supported only on MATALB 14']) ;
	  continue;
	end
        use_outer = 1 ;
        otherwise
          error(['Box is either ''inner'' or ''outer''']) ;
      end
    otherwise
      error(['Uknown parameter ''', varargin{a}, '''.']) ;
  end      
end

% --------------------------------------------------------------------
%                                                  Check the arguments
% --------------------------------------------------------------------

[j,i]=ind2sub([N M],p) ;
i=i-1 ;
j=j-1 ;

dt = sp/2 ;
db = sp/2 ;
dl = sp/2 ;
dr = sp/2 ;

pos = [  j*1/N+dl,...
       1-i*1/M-1/M+dt,...
       1/N-dl-dr,...
       1/M-dt-db] ;

switch use_outer
  case 0
    H = findobj(gcf, 'Type', 'axes', 'Position', pos) ;
    if(isempty(H))
      H = axes('Position', pos) ;
    else
      axes(H) ;
    end
    
  case 1
    H = findobj(gcf, 'Type', 'axes', 'OuterPosition', pos) ;
    if(isempty(H))
      H = axes('ActivePositionProperty', 'outerposition',...
               'OuterPosition', pos) ;
    else
      axes(H) ;
    end
end    
