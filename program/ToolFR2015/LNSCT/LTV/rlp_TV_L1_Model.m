function prob=rlp_TV_L1_Model(F,lambda)
% prob=rlp_tv_l1_relaxed(F,lambda)
% F: double matrix, the input image to be decomposed
% lambda: the scale parameter
% size of image F. size(F) = M x N

[M,N]=size(F);

% useful constants
MN = M*N;
MNm = M*(N-1);
MmN = (M-1)*N;
MmNm = (M-1)*(N-1);
Nm = N-1;
Mm = M-1;

tempfile=sprintf('coeff_rlp_tv_l1_model_%d_%d.mat',M,N);
if exist(tempfile)
% 	fprintf(1,'Loading coefficients from file...\n');
    load(tempfile,'prob');
% 	fprintf(1,'Coefficients loaded from file.\n');
else
	
% 	fprintf(1,'Generating coefficients...\n');

	tmp = 3*(MmN+MNm)+2*MN;
	x=zeros(1,tmp);     % 产生tmp大小的全0行向量
	y=zeros(1,tmp);
	s=zeros(1,tmp);
	
	clear tmp;

	lg=0;
	row=0;
	
	% some index matrices 矩阵大小都是M*N
	block1 = reshape(1:MN,M,N);						% v_ij
	block21 = reshape((MN+1):3:(MN+3*MN),M,N);		% t_ij
	block22 = reshape((MN+2):3:(MN+3*MN),M,N);		% (partial_x u)_ij
	block23 = reshape((MN+3):3:(MN+3*MN),M,N);		% (partial_x u)_ij
	block3 = reshape((4*MN+1):(5*MN),M,N);			% s_ij
	
	%--------------------1----------------------
	% (partial_x u)_ij + v_i+1,j - v_ij = (F_i+1,j - F_ij)  for i=1,...,M-1, j=1,...,N
	% total # of nonzeros = 3*MmN

	left=lg+1;
	right=lg+3*MmN;
	lg=right;
	
	%%% Skip (M,j) for all j
	x(left:right) = repmat(1:MmN,1,3);    % 以1:MmN作为块，构造1行三列的矩阵
	y(left:right) = [	reshape(block1(1:Mm,:),1,MmN),...	% v_ij
						reshape(block1(2:M ,:),1,MmN),...	% v_i+1,j
						reshape(block22(1:Mm,:),1,MmN)];	% (partial_x u)_ij
	s(left:right) = [-ones(1,MmN),ones(1,2*MmN)];

    row=row+MmN;
	
	%--------------------2----------------------
	% (partial_y u)_ij + v_i,j+1 - v_i,j = (F_i,j+1 - F_ij) for j=1,...,N-1
	% total # of nonzeros = 3*MNm

	left=lg+1;
	right=lg+3*MNm;
	lg=right;
	
	%%% Skip (i,N) for all i
	x(left:right) = repmat((row+1):(row+MNm),1,3);    % 
	y(left:right) = [	reshape(block1(:,1:Nm),1,MNm),...	% v_ij
						reshape(block1(:,2:N ),1,MNm),...	% v_i+1,j
						reshape(block23(:,1:Nm),1,MNm)];	% (partial_y u)_ij
	s(left:right) = [-ones(1,MNm),ones(1,2*MNm)];

    row=row+MNm;
	
	%--------------------3----------------------
	% s_i,j - 2v_i,j >= 0
	% total # of nonzeros = 2*MN

	left=lg+1;
	right=lg+2*MN;
	lg=right;
	
	x(left:right) = repmat((row+1):(row+MN),1,2);
	y(left:right) = [	block3(:),...		% s_ij
						block1(:)];			% v_ij
	s(left:right) = [ones(1,MN) repmat(-2,1,MN)];
	
	row=row+MN;
	
    %% The all-zero columns in A will be removed later %%
	prob.a = sparse(x,y,s,row,5*MN);
    
    clear x y s left right lg row;  

	%-------------- prob.c ------------------------
	prob.c = [	repmat(-lambda,MN,1);...	% -lambda*v
      repmat(sparse([1;0;0]),MN,1);...		% TV
      repmat(lambda,MN,1)];					% lambda*s

	%%%%%%%%%%%% remove all-zero columns from c' and A %%%%%%%%%%%%
	% (partial_y u)_ij for all i and j=N
	% (partial_x u)_ij for i=M and all j
	% t_MN
	% total: M+N+1

	coltoberemoved = [	reshape(block23(:,N),1,M),...		%	(partial_y u)_ij for all i and j=N
						reshape(block22(M,:),1,N),...		%	(partial_x u)_ij for i=M and all j
						block21(M,N)];						%	t_MN
	col = true(1,length(prob.c));
	col(coltoberemoved) = false;

	prob.a=prob.a(:,col);
	prob.c=prob.c(col);
	
	clear col coltoberemoved;
	
	%-------------- prob.cones ------------------------
    %% Assuming that all-zero columns in A will be removed later %%
	prob.cones=cell(MN-1,1);

	col = MN;
	ind = 1;
	for j = 1:Nm
        for i = 1:Mm
            prob.cones{ind}.type = 'MSK_CT_QUAD';
            prob.cones{ind}.sub = col+[1:3];
            
			ind = ind+1;
			col = col+3;
		end
		
        prob.cones{ind}.type = 'MSK_CT_QUAD';
        prob.cones{ind}.sub = col+[1 2];

		ind = ind+1;
		col = col+2;
	end
    % for j=N
    for i=1:Mm
        prob.cones{ind}.type = 'MSK_CT_QUAD';
        prob.cones{ind}.sub = col + [1 2];

		ind = ind+1;
		col = col+2;
	end

	%-------------- prob.blx blx ------------------------
	prob.blx = [repmat(-inf,4*MN-M-N-1,1); zeros(MN,1)];
	prob.bux = repmat(inf,5*MN-M-N-1,1);

	save(tempfile,'prob');
	
% 	fprintf(1,'Coefficents generated.\n');

end


% ----------------- prob.blc and buc --------------------

prob.blc=zeros(MmN+MNm+MN,1);

prob.blc(1:MmN) = reshape(F(2:M,:)-F(1:Mm,:),MmN,1);
prob.blc((MmN+1):(MmN+MNm)) = reshape(F(:,2:N)-F(:,1:Nm),MNm,1);

prob.buc=[prob.blc(1:(MmN+MNm));repmat(inf,MN,1)];

% ----------------- update prob.c --------------------

prob.c(1:MN) = -lambda;
prob.c((end-MN+1):end) = lambda;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%