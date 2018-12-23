%PLOTF Plot feature distribution
% 
% 	h = plotf(A)
% 
% Produces 1-D density plots for the features in dataset A. The 
% densities are estimated using parzenml.
% 
% See also datasets, parzenml

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function h_out = plotf(a)
[nlab,lablist,m,k,c] = dataset(a);
if c == 2
	map = [1 0 0; 0 0 1];
else
	map = hsv(c);
end
h = [];
if k > 3
	p = ceil(k/2); q = 2;
else
	p = k; q = 1;
end
for j = 1:k
	b = a(:,j);
	s = zeros(1,c);
	d = zeros(121,c);
	bb = [-0.10:0.01:1.10]' * (max(b)-min(b)) + min(b);
	ex = 0;
	for i = 1:c
		I = find(nlab==i);
		D = +distm(bb,b(I));
		[s(i),ex] = parzenml(b(I),ex);
		d(:,i) = sum(exp(-D/(s(i).^2)),2)./(length(I)*s(i));;
	end
	subplot(p,q,j)
	plot(bb,zeros(size(bb)),'w.');
	hold on
	h = [];
	for i = 1:c
		I = find(nlab==i);
		hh = plot(b(I),zeros(size(b(I))),'x',bb,+d(:,i));
		set(hh,'color',map(i,:));
		h = [h;hh];
	end
	title(['feature' num2str(j)]);
	hold off
end
if k == 1, title(''); end
if nargout > 1
	h_out = h;
end
return
