function a = subassign(a,s,b)
[m,k] = size(a);
col = [];
row = [];
if length(s.subs) == 1 
	if isempty(s.subs{1})
		return
	else
		J = s.subs{1};
		if isa(b,'dataset')
			a.d(J) = b.d;
		else
			a.d(J) = b;
		end
		return
%		error('Unparsable assignment for datasets')
	end
elseif length(s.subs) == 2
	if strcmp(s.subs{1},':')
		if strcmp(s.subs{2},':')
			if isa(b,'dataset')
				a = b;
			else
				a.d = b;
			end
			return
		end
% 		if isempty(b)
% 			for sub = s.subs{2}(:)'
% 				a.d(:,sub) = [];
% 				a.f(sub,:) = [];
% 			end
% 		else
			j = 0;
			for sub = s.subs{2}(:)'
				j = j + 1;
				if isa(b,'dataset')
					a.d(:,sub) = b.d(:,j);
					a.f(sub,:) = b.f(j,:);
				else
					a.d(:,sub) = +b(:,j);
				end
			end
% 		end
		return
	else
		col = s.subs{1};
	end
	if ~isa(a.ll,'cell')
		a = dataset(a);
	end
	if ~isa(a.l,'dataset')
		laba = a.ll{1}(a.l,:);
	else
		laba = a.l;
	end
	if strcmp(s.subs{2},':')
%   		if isempty(b)
% 			for sub = flipud(sort(s.subs{1}))
% 				a.d(sub,:) = [];
% 				if isa(laba,'dataset')
% 					laba.d(sub,:) = [];
% 				else
% 					laba(sub,:) = [];
% 				end
% 			end
% 		else
			if isa(b,'dataset')
				if ~isa(b.l,'dataset')
					labb = b.ll{1}(b.l,:);
				else
					labb = b.l;
				end
			end
			j = 0;
			for sub = s.subs{1}(:)'
				j = j + 1;
				if isa(b,'dataset')
					a.d(sub,:) = b.d(j,:);
					if isa(laba,'dataset')
						laba.d(sub,:) = labb.d(j,:);
					else
						laba(sub,:) = labb(j,:);
					end
				else
					a.d(sub,:) = b(j,:);
				end
			end
% 		end
	else
		row = s.subs{2};
	end
	if ~isempty(row) & ~isempty(col)
		a.d(col,row) = +b;
	end
else
	error('Wrong number of subscripts')
end
if isa(laba,'dataset')
	a.l = laba;
else
	a.l = renumlab(laba);
end
return
	
