topX = 1;
testlen = size(testWeights,2);
trainlen = size(trainWeights,2);
index = zeros(testlen,topX);
resultIds = zeros(testlen,topX);
resultDist = zeros(testlen,topX);

trainWeights(isnan(trainWeights)) = 0;
testWeights(isnan(testWeights)) = 0;

fprintf('Test: %0.6d\r', 0);
for i = 1:testlen
	fprintf('\b\b\b\b\b\b\b%0.6d\r', i);
	z = chi2_mex_float(single(testWeights(:,i)), single(trainWeights));
	for j = 1:topX
		[best, index(i, j)] = min(z);
		resultIds(i, j) = fbgTrainIds(index(i, j));
		resultDist(i, j) = best;
		z(index(i, j)) = Inf; % Remove best

		% Keep searching until we have a new person because we the first
		% two hits might be the same person (wrong code)
		if j > 1
			while sum(resultIds(i, 1:j-1) == resultIds(i, j)) > 0
				[best, index(i, j)] = min(z);
				resultIds(i, j) = fbgTrainIds(index(i, j));
				resultDist(i, j) = best;
				z(index(i, j)) = Inf; % Remove best		
			end
		end
	end	
end

[r,c] = size(resultDist);
distMatrix = zeros(r,c*2+1);
distMatrix(:,1:c) = resultDist;
distMatrix(:,c+1:2*c) = resultIds;
distMatrix(:,end) = fbgTestIds;
if exist('fbgMethod', 'var')
	save([fbgStatsFolder '/' fbgMethod '/' fbgDataset '_dist.txt'], 'distMatrix', '-ASCII');
end

% Store the number of correct
if topX > 1
    resultMatrix = (resultIds == repmat(fbgTestIds, 1, topX));
    results = max(resultMatrix, [], 2);
else
    resultMatrix = (resultIds == fbgTestIds);
    results = max(resultMatrix, [], 2);
end

correct = find(results == 1);
fbgAccuracy = 100* length(correct) / size(fbgTestIds,1);