% GO_RANDKEY Scan the database to generate random keypoints
%
%   We simulate the feature distribution proposed by
%
%   [1] E. Nowak, F. Jurie, and B. Triggs, "Sampling strategies for
%       bag-of-features image classification," in Proc. ECCV, 2006.
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

dir_list = dir(pfx_images) ;  
for dn = {dir_list([dir_list.isdir]).name}
  if(strcmp(dn{1},'.') || strcmp(dn{1},'..'))
    continue ;
  end
  dir_name = dn{1} ;     
  out_dir_name = fullfile(pfx_key, dn{1}) ;
  if(~exist(out_dir_name)), mkdir(pfx_key, dir_name) ; end
    
  file_list = dir([fullfile(pfx_images, dir_name) '/*.jpg']) ;
  for fn = {file_list.name}
    [discard,name]=fileparts(fn{1}) ;
    file_name = fullfile(pfx_images, dir_name, fn{1}) ;
    rkey_name = fullfile(pfx_key, dir_name, [name '.key']) ;
    
    finfo = imfinfo(file_name) ;
    M = finfo.Height ;
    N = finfo.Width ;
		
		% min/max size of a feature
    rmin = 6*data_min_sigma ;
    rmax = min(M,N)/2 ;
    
		% we select the size according to this distribution
    r_range=rmin:rmax ;
    p=M*N - 2*(M+N)*r_range +4*r_range.^2 ;
    p=p./sum(p) ;
    P=cumsum(p) ;
    P=[0 P(1:end-1)] ;

    K = 5000 ; 
    f = zeros(4,K) ;
    
    for k=1:K
      rn=rand; 
      sel=find(P<rn) ;
      r=r_range(max(sel));

      w = N - 2*r ;
      h = M - 2*r  ;
      C = [w * rand + r ; h * rand + r] ;
      sigma = r / 6 ;

      f(:,k) = [C;sigma;0] ;
    end

    f=f' ;
    save(rkey_name,'f','-ASCII') ;
    
    fprintf('Done ''%s''\r', file_name) ;
  end % for fn
end % for dn
