% GO_CONFIG   GO_* scripts configuration
%
%  See GO_TREE(), GO_SIGN(), GO_STAT(), GO_CLASSIFY().

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

% data_min_sigma          Build database: drop features smaller than this
% data_shuffle            Build database: shuffle images in categories
%                         after loading them.
% tree_fair_data          Build k-tree: uses same amount of features from
%                         each category.
% tree_limit_data         Build k-tree: sample this many features (%) from
%                         all possible features.
% tree_K                  K-tree K.
% tree_nleaves            K-tree approximate number of leaves.
% tree_restrict_to_train  Learn K-tree only on training set.
% class_ntrain            NN classifier: number of training images
% class_nvotes            NN classifier: number of votes to take

% select a set of configuration parameters
which_exp = 3 ;

switch which_exp
 case 1
	pfx_images     = '~/data/caltech-4/' ;
	pfx_sift       = '~/extra/caltech-4/std-sift/' ;
	pfx_ktree      = '~/extra/caltech-4/std-tree' ;
	pfx_classifier = '~/extra/caltech-4/std-class' ;

	data_min_sigma          = 1 ;
	data_shuffle            = 1 ;
	
	tree_fair_data          = 1 ;   
	tree_limit_data         = 0.1 ; 
	tree_K                  = 10 ;
	tree_nleaves            = 10000 ;
	tree_restrict_to_train  = 0 ;

	stat_downsample         = 10 ;	
	
	class_ntrain            = 100 ;
	class_nvotes            = 10 ;
	
 case 2
	pfx_images     = '~/data/caltech-4/' ;
	pfx_sift       = '~/extra/caltech-4/rand-sift/' ;
	pfx_key        = '~/extra/caltech-4/rand-key/' ;
	pfx_tree       = '~/extra/caltech-4/rand-tree' ;
	pfx_classifier = '~/extra/caltech-4/rand-class' ;
	
	data_min_sigma          = 1 ;
	data_shuffle            = 1 ;
	
	tree_fair_data          = 1 ;   
	tree_limit_data         = 0.1 ; 
	tree_K                  = 10 ;
	tree_nleaves            = 10000 ;
	tree_restrict_to_train  = 0 ;

	stat_downsample         = 10 ;	
	
	class_ntrain            = 100 ;
	class_nvotes            = 10 ;
	
 case 3
	pfx_images     = '~/data/caltech-4/' ;
	pfx_sift       = '~/extra/caltech-4/rand-sift/' ;
	pfx_key        = '~/extra/caltech-4/rand-key/' ;
	pfx_tree       = '~/extra/caltech-4/rand-tree-s' ;
	pfx_classifier = '~/extra/caltech-4/rand-class-s' ;
	
	data_min_sigma          = 1 ;
	data_shuffle            = 1 ;
	
	tree_fair_data          = 1 ;   
	tree_limit_data         = 1 ; 
	tree_K                  = 10 ;
	tree_nleaves            = 10000 ;
	tree_restrict_to_train  = 1 ;

	stat_downsample         = 10 ;	
	
	class_ntrain            = 100 ;
	class_nvotes            = 10 ;

 case 4
	pfx_images     = '~/data/caltech-101/' ;
	pfx_sift       = '~/extra/caltech-101/rand-sift/' ;
	pfx_key        = '~/extra/caltech-101/rand-key/' ;
	pfx_tree       = '~/extra/caltech-101/rand-tree' ;
	pfx_classifier = '~/extra/caltech-101/rand-class' ;
	
	data_min_sigma          = 1 ;
	data_shuffle            = 1 ;
	
	tree_fair_data          = 1 ;   
	tree_limit_data         = 0.1 ; 
	tree_K                  = 10 ;
	tree_nleaves            = 10000 ;
	tree_restrict_to_train  = 1 ;

	stat_downsample         = 10 ;	
	
	class_ntrain            = 30 ;
	class_nvotes            = 5 ;


end
