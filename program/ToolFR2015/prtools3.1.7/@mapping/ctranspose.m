function w = ctranspose(w)
if w.s
	error('transpose not defined for classifiers')
end
if strcmp(w.m,'sequential')
	w = w.d{2}'*w.d{1}';
elseif strcmp(w.m,'affine')
	w.l = [];
	c = w.c;
	k = w.k;
	w.c = k;
	w.k = c;
	v = sum(w.d(1:k,:).*w.d(1:k,:));
	w.d(1:k,:) = w.d(1:k,:)./repmat(v,k,1);
	w.d = [w.d(1:k,:)';-w.d(k+1,:)*w.d(1:k,:)'];
	w.v = 1;
	if ~isempty(w.p), w.p = - w.p; end
else
	error(['mapping transpose not defined for type ' w.m]);
end
return
