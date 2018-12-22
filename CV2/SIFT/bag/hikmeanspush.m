function asgn = hikmeanspush(tree,data)
% HIKMEANSPUSH   Push data down an integer K-means tree
%   ASGN=HIKMEANSPUSH(TREE,DATA) assigns data point DATA to
%   nodes of the hierachical K-means tree TREE.
%   See also HIKMEANS().
%

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

asgn = xpush(tree,data,tree.depth) ;

% --------------------------------------------------------------------
function asgn = xpush(tree,data,depth)
% --------------------------------------------------------------------
% Recusrively partition data

N    = size(data,2) ;
M    = size(data,1) ;
asgn = uint32(zeros(depth, N)); 

if(~isstruct(tree)), return ; end

this_asgn = ikmeanspush(data,tree.centers) ;
asgn(1,:) = this_asgn ;

% recursively descend in each subtree
if depth > 1
  K_eff = size(tree.centers,2) ;
  for k=1:K_eff  
    sel=find(asgn(1,:)==k) ;
    if(isempty(sel)), continue ; end
    sub_asgn = xpush(tree.sub(k),data(:,sel),depth-1) ;
  	asgn(2:end,sel) = sub_asgn ;
  end
end
