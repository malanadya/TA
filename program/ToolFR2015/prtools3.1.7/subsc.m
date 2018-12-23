%SUBSC Subspace Classifier
%
%	W = subsc(A,n)
%
% n-dimensional subspace maps are computed for each class of the dataset A
% using PCA, such that they contain the origin. All object in A are normalized
% first on unit length.
%
%	W = subsc(A,alf)
%
% Subspaces of different dimensionality are determined, each explaining at
% least a fraction alf of the class variance.
%
% See datasets, mappings, fisherc, fisherm, klm, subsm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = subsc(a,n);
if nargin < 2, n = 1; end
if nargin < 1 | isempty(a) % handle untrained calls
	W = mapping('subsc',n);
	return
end
[nlab,lablist,m,k,c,p] = dataset(a);
if isa(n,'double') % training
	W = {};
	N = zeros(1,c);
	for j = 1:c
		J = find(nlab==j);
		[w,nn] = subsm(+a(J,:),n);
		W = [W,{w}];
		N(j) = nn;
	end
    %W è ancora l'insieme delle proiezioni
	W = mapping('subsc',W,lablist,k,c,1);
    %ora W è un mapping
	W = cnormc(W,a);
elseif isa(n,'mapping')			% calcolo le similarità
	[W,classlist,type,k,c] = mapping(n);
	b = zeros(size(a,1),c);%b conterrà le similarità
	for j = 1:c
		d = a*normm(2)*W{j};%normalizzo e proietto nel sottospazio
		b(:,j) = sqrt(sum(d.*d,2));%calcolo le norme,  perchè????
	end
	b = b ./ repmat(sum(b,2),1,c);%normalizzo
	W = dataset(invsig(b),getlab(a),classlist,p,lablist);
    %invsig(a) a = log(a+realmin) - log(1-a+realmin); REALMIN Smallest positive floating point number.
else
	error('error')
end

