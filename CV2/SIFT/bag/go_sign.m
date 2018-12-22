% GO_SIGN Scan database to compute image signatures
%   This is from
%
%   [1] D. Nister and H.Stewenius, "Scalable recognition with a
%   vocabulary tree," in Proc. CVPR, 2006.
%   
%   See GO_TREE().

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

% retrieve tree database
load(pfx_tree);
N=length(database);

% --------------------------------------------------------------------
% compute signature of images
% --------------------------------------------------------------------

% project the whole database
fprintf('Pushing database down the tree ...\n') ;
for k=1:N
	% load keys
	key_name = database(k).name ;
	f = load(key_name, '-ASCII')' ;
	
	% load descriptors
	[path,name]=fileparts(key_name) ;
	desc_name = fullfile(path,[name '.desc']) ;
	fd=fopen(desc_name,'r','l') ; 
	d =fread(fd,[128,size(f,2)],'uint8=>uint8') ;
	fclose(fd) ;
		
	% throw away small features
	sel = find(f(3,:) >= data_min_sigma) ;
	f = f(:,sel) ;
	d = d(:,sel) ;
				
	% push down the tree and compute signature
	asgn = hikmeanspush(tree,d) ;
	sign = signdata(tree_K,tree.depth,asgn) ;
	
	database(k).asgn = asgn ;
	database(k).sign = sign ;
	fprintf('done %d of %d.\r',k,N) ;
end
	
fprintf('\nMangling singatures ...\n') ;

% compute usage of tree nodes
L=size(database(1).sign,1) ;
usage=zeros(L,1) ;
for k=1:N
	sel=find(database(k).sign) ;
	usage(sel) = usage(sel) + 1 ;
end

% compute weights based on node usage
sel = find(usage) ;
weights = zeros(size(usage));
weights(sel) = log( N ./ usage(sel) ) ;

% * Reweight and normalize signatures *
%
% Note that for a certain value of cutoff, at most a certain
% amount of bins can be zero. In fact we need to have:
%   cutoff > 1 / #(non-zero-bins)
%
cutoff = 0.01 ; % 0.05 

% for a given 
for k=1:N
	
	sign = double(database(k).sign) ;
	sign = sign .* weights ;
	sign = sign / sum(sign) ;
	
	% choose a thiscut value such that
	%
	%  thiscut <= cutoff sum( min(sign, thiscut) ) 
	%
	% we quickly search for thiscut by ordering sign by increasing
	% values. We do this so that after cutoff and normalization
	% the max. val. of the signature is equal to cutoff.
	sorted_sign = sort(sign) ;
	part        = cumsum( sorted_sign ) + (L-1:-1:0)' .* sorted_sign - sorted_sign / cutoff ;
	best        = max(find(part>=0)) ;
	thiscut     = sorted_sign(best) ;
	
	% ops: this descriptor is too sparse to be correctly
	% represented and causes overflow.
	if thiscut == 0
		warning(sprintf('Image %d caused signature to overflow!', k)) ;
		thiscut = max(thiscut, 1/L) ;
	end
	
	% now cut
	sign = min(sign, thiscut) ;
	sign = sign / sum(sign) ;
	
	% now quantize, but make sure the sum is always equal to
	% 255/cutoff. Note: only in case of overflow we might need to
	% add units to null elements.
	sign = floor(255 * sign / cutoff) ;
	rem = round(255/cutoff) - sum(sign) ;
	sel = [ find(sign & sign < 255); find(sign==0) ] ;
	sign(sel(1:rem)) = sign(sel(1:rem))+1 ;				
	
	% save
	database(k).sign = uint8(sign) ;
end

% done
save(pfx_tree, 'tree', 'database') ;
