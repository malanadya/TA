function [tree,asgn] = hikmeans(data,K,nleaves)
% HIKMEANS  Hierachical integer K-means
%   [TREE,ASGN] = HIKMENAS(DATA,K,NLEAVES) applies recursive K-menas
%   to data DATA. The depth of the recursion is computed so that about
%   NLEAVES are generated.
%
%   HIKMEANS() requires the data to be of class `uint8' (hence the
%   `I' suffix.
%
%   TREE is a structure representing the hierarchical clusters.
%   Each node of the tree is represented by a structure with fields
%   
%   .DEPTH    Depth of the tree (only at the root node)
%   .CENTERS  K cluster centers
%   .SUB      Array of K node structures representing subtrees 
%             (ony at the internal nodes)
%
%   ASGN is a matrix with one column per datum and height equal to the
%   depth of the tree. Each column encodes the branch of the tree
%   that correspond to each datum. 
%
%   Examples:
%
%     ASGN(:,7) = [1 5 3] means that the tree as depth equal to 3 and
%     that the datum X(:,7) corresponds to the branch
%     ROOT->SUB(1)->SUB(5)->SUB(3).

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

depth = ceil(log(nleaves)/log(K)) ;
[tree,asgn] = xmeans(data,K,depth,depth) ;
tree.depth = depth ;

% --------------------------------------------------------------------
function [tree,asgn] = xmeans(data,K,depth,maxdepth)
% --------------------------------------------------------------------
% Recursively compute K-means on sub-clusters

[this_centers,this_asgn] = ikmeans(data,K) ;

% Some clusters might be un-assigned. We remove them.
not_empty         = unique(this_asgn) ;
K_eff             = length(not_empty) ;
rename            = uint32(zeros(1,K)) ;
rename(not_empty) = uint32(1:K_eff) ;

% This level is done
N            = size(data,2) ;
asgn         = uint32(zeros(depth,N)) ;
asgn(1,:)    = rename(this_asgn) ;
tree.centers = this_centers(:,not_empty) ;

% Recursively descend in each subtree
N_done = 0 ;
for k=1:K_eff
  if(depth == 1), tree.sub(k) = 0 ; continue ; end
	sel=find(asgn(1,:)==k) ;
  N_eff = length(sel) ;
  if(isempty(sel)), keyboard ; end
	[sub_tree, sub_asgn] = xmeans(data(:,sel),min(K,N_eff),depth-1,maxdepth) ;
  
	tree.sub(k)     = sub_tree ;
	asgn(2:end,sel) = sub_asgn ;
	
	N_done = N_done + N_eff ;
	if(depth==maxdepth)		
		fprintf('hikmeans: %.1f %% done\n',100 * N_done / N) ;
	end
end


