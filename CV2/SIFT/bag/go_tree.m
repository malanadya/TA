% GO_TREE_NEW  Scan the database to build K-tree dictionary
%   This is from
%
%   [1] D. Nister and H.Stewenius, "Scalable recognition with a
%   vocabulary tree," in Proc. CVPR, 2006.
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

go_config ;

% --------------------------------------------------------------------
% scan corpus
% --------------------------------------------------------------------
if exist('database') ~= 1
  
  k = 1 ; % database entry index
  c = 1 ; % category index
	
	dir_list = dir(pfx_sift) ;  
	for dn = {dir_list([dir_list.isdir]).name}
		if(strcmp(dn{1},'.') || strcmp(dn{1},'..'))
			continue ;
		end
    dir_name = dn{1} ;
		
		i = 1 ; % image index
		
		file_list = dir([fullfile(pfx_sift, dir_name) '/*.key']) ;
		for fn = {file_list.name}
			key_name = fullfile(pfx_sift, dir_name, fn{1}) ;
			database(k).name   = key_name ;
			database(k).cat_id = c ;
			database(k).im_id  = i ;
			i=i+1 ;
			k=k+1;
			fprintf('Scanned ''%s''\r', key_name) ;
		end % for fn
		c=c+1 ;
  end % for dn
	fprintf('\nDatabase scanned.\n') ;

	% ------------------------------------------------------------------
	% shuffle corpus
	% ------------------------------------------------------------------
	if data_shuffle
		cats=unique([database.cat_id]) ;
		fprintf('Shuffling database ...\n') ;
		for c=cats
			sel=find([database.cat_id]==c) ;
			psel=sel(randperm(length(sel))) ;
			database(sel) = database(psel) ;
		end
	end
	
	% ------------------------------------------------------------------
	% divide into training and testing
	% ------------------------------------------------------------------
	fprintf('Dividing into training and testing...\n') ;
	for c=cats	
		sel=find([database.cat_id]==c) ;
		K=min(length(sel),class_ntrain) ;
		for k=sel(1:K),     database(k).is_train = 1 ; end
		for k=sel(K+1:end), database(k).is_train = 0 ; end
	end
	
end

% --------------------------------------------------------------------
% load features and descriptors
% --------------------------------------------------------------------
if ~isfield(database,'f')
	fprintf('Loading features...\n') ;
	for k=1:length(database)
		% load keys
		key_name = database(k).name ;
		f = load(key_name,'-ASCII')' ;
		M = size(f,2) ;
		
		% load descriptors
		[path,name] = fileparts(key_name) ;
		desc_name = fullfile(path, [name '.desc']) ;
		fd=fopen(desc_name,'r','l') ; 
		d =fread(fd,[128,size(f,2)],'uint8=>uint8') ;
		fclose(fd) ;
		
		% throw away small features
		sel = find(f(3,:) >= data_min_sigma) ;
		f = f(:,sel) ;
		d = d(:,sel) ;
		
		% throw away excess features
		N = size(d,2) ;
		perm = randperm(N) ;
		N_keep = ceil(tree_limit_data*N) ;
		sel = perm(1:N_keep) ;
		
		% throw away features if this is not training data
		if tree_restrict_to_train && ~ database(k).is_train
			sel = [] ;
		end
		
		% save to structure
		database(k).name   = key_name ;
		database(k).f      = f(:,sel) ;
		database(k).d      = d(:,sel) ;
		database(k).nfeats = M ;
		
		fprintf('Loaded ''%s''\r', key_name) ;
	end 
	fprintf('\nFeatures loaded.\n') ;
end

% --------------------------------------------------------------------
% build tree of descriptors
% --------------------------------------------------------------------
N=length(database);

if tree_fair_data
	% pick the same number of features for each category	
	fprintf('Collect faired data from categories ...\n') ;
	
	cats = unique([database.cat_id]) ;
	ncats = length(cats) ;
	nfeats = zeros(1,N) ;
	for k=1:N
		nfeats(k) = size(database(k).d,2) ;
	end
	
	nfeats_cat = zeros(1,ncats) ;
	for c=1:ncats
		sel = find([database.cat_id]==c) ;
		nfeats_cat(c) = sum(nfeats(sel)) ;
	end
	
	maxfeats = min(nfeats_cat) ;
	fprintf('Faried data: %d features/category\n', maxfeats) ;
	
	D = size(database(1).d,1) ;
	data = uint8(zeros(D,maxfeats*ncats)) ;
	for c=1:ncats
		sel      = find([database.cat_id]==c) ;		
		data_cat = [database(sel).d] ;
		perm     = randperm(size(data_cat,2)) ;
		
		data(:,maxfeats*(c-1) + (0:maxfeats-1) +1) = ...
				data_cat(:,perm(1:maxfeats)) ;
	end
	
else
	% use all available data
	fprintf('Collecting all data from categories ...\n') ;
	data = [database.d] ;
end

% now build the tree
fprintf('Building k-tree ...\n') ;
[tree,asgn] = hikmeans(data,tree_K,tree_nleaves) ;

% delete this extra field to save (a lot of) space
database=rmfield(database,'d') ;
database=rmfield(database,'f') ;
save(pfx_tree, 'tree', 'database') ;
