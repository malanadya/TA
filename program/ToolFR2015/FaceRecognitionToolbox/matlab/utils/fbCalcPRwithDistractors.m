function [P,R,T] = fbCalcPRwithDistractors(totDist, distractDist, inc)

	totDist(:,1) = totDist(:,1);
	[sdist,ind] = sort(totDist(:,1), 'ascend');
	totDist = totDist(ind,:);
	P = [];
	R = [];
	T = [];
	if ~exist('inc', 'var')
		inc = 1000;
	end
	len = length(sdist);
	range = [1:inc:len len];
	for i = range
		R = [R double(i)/len];
        numD = 0;
        try
            numD = length(find(distractDist(:,1) <= totDist(i,1)));
        end
		num = double(i) +  numD;
		acc = sum(totDist(1:i,2) == totDist(1:i,3)) / num;
		P = [P acc];
		T = [T totDist(i,1)];
	end
end