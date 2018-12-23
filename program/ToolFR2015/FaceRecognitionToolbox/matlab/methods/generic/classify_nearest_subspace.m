% Build class indexes
classes = unique(fbgIds);
numClasses = length(classes);
classIndex = cell(numClasses,1);
for i = 1:numClasses
	classIndex{i} = find(fbgTrainIds == classes(i));
end

%topX = 1; % For now, it's easier this way...do want to test this out though
testlen = size(testWeights,2);
trainlen = size(trainWeights,2);
index = zeros(numClasses,topX);
resultIds = zeros(numClasses,topX);
resultDist = zeros(numClasses,topX);
x2 = sum(testWeights.^2)';
y2 = sum(trainWeights.^2);

if fbgDoNSProjection
	for j = 1:numClasses
		Ainv{j} = pinv(trainWeights(:,classIndex{j}));
	end
end

subZ = zeros(numClasses,1);
for i = 1:testlen
    z = testWeights(:,i)'*trainWeights;
    z = repmat(x2(i),1,trainlen) + y2 - 2*z;
    %[C, index(i)] = min(z);
	
	% Comapre the holistic distance to each class
	for j = 1:numClasses
		if fbgDoNSProjection
			A = trainWeights(:,classIndex{j});
			subZ(j) = norm(A*(Ainv{j}*testWeights(:,i)) - testWeights(:,i));
		else
			% Wrong way to do it I think, but gets better results than above
			subZ(j) = mean(z(classIndex{j}));
			% Can also do it with RMSEs
			%subZ(j) = sqrt(sum(z(classIndex{j}).^2) / length(classIndex{j}));
		end
	end
	
	for j = 1:topX
		[best, index(i, j)] = min(subZ);
		resultIds(i, j) = classes(index(i, j));
		resultDist(i, j) = best;
		subZ(index(i, j)) = Inf; % Remove best
	end
end

% Store the number of correct
if topX > 1
    resultMatrix = (resultIds == repmat(fbgTestIds, 1, topX));
    results = max(resultMatrix, [], 2);
else
    resultMatrix = (resultIds == fbgTestIds);
    results = max(resultMatrix, [], 2);
end
