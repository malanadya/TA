resolution = 1000;
inc = 1;
pvals = 0.95;   % Precision for which we compute recall

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Precision and Recall
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indLen = length(algos);
totTimeAll = cell(length(algos),length(friends));
tstTimeAll = cell(length(algos),length(friends));
trnTimeAll = cell(length(algos),length(friends));
trnTimeAllnoMean = cell(length(algos),length(friends));
allRank = {};
for i = 1:indLen
	allRank{i} = [];
	totDist = [];
	totDistractDist = [];
	PInd = [];
	TInd = [];
	WInd = [];
	for ii = 1:length(friends)
		curDist = [];
		curDistractDist = [];
		totTimes = 0;
        PIndF = [];
		for jj = start:repetitions(ii)-1
			rep = jj;
			if isempty(dirPrefix{1})
                accFile = fullfile(inpath,algos{i},sprintf('%s_%0.4d_%0.4d%s_cacc.mat',datasets{i}, friends(ii), rep, datasets{i}));
			else
				% Load from directory
				accFile = fullfile(inpath,algos{i},[dirPrefix{1} sprintf('%s_%0.4d_%0.4d%s_cacc.mat', datasets{i}, friends(ii), rep, datasets{i})]);
				if ~exist(accFile, 'file')
					accFile = fullfile(inpath,algos{i},[dirPrefix{1} sprintf('%s_%0.4d_%0.4d%s_acc.mat', datasets{i}, friends(ii), rep, datasets{i})]);
				end
				if ~exist(accFile, 'file')
                    accFile = fullfile(inpath, algos{i}, [dirPrefix{1}(length('dataset')+1:end) sprintf('%s_%0.4d_%0.4d%s_acc.mat', datasets{i}, friends(ii), rep, datasets{i})]);
				end
			end
			
			if ~exist(accFile, 'file')
				d = dir(fullfile(inpath, algos{i}, sprintf('*_%0.4d_%0.4d*_cacc.mat', friends(ii), rep)));
				if length(d) == 1
                    accFile = fullfile(inpath,algos{i},d(1).name);
				end
			end
			
			clear fbgAccuracy numTest numTrain custConf distractCustConf;
			load(accFile);
			
			if exist('cdistMatrix', 'var') && ~isempty(cdistMatrix)
				c = cdistMatrix(1:end-1,1:end-2);
				guess = cdistMatrix(1:end-1,end-1);
				truth = cdistMatrix(1:end-1,end);
				lookup = cdistMatrix(end,1:end-2);
				rank = zeros(size(c,1),1);
				rlookup = zeros(max(lookup),1);
				for j = 1:length(lookup)
					rlookup(lookup(j)+1) = j;
				end
				for j = 1:size(c,1)
					[sv,si] = sort(c(j,:), 'ascend');
					r = find(si == rlookup(truth(j)+1));
					if isempty(r)
						r = length(lookup)+1;
					end
					rank(j) = r;
				end

				allRank{i} = [allRank{i}; rank];
			end

			if ~exist('totTime', 'var'), totTime = -1e6; end;
			if ~exist('testTime', 'var'), testTime = -1e6; end;
			if ~exist('trainTime', 'var'), trainTime = -1e6; end;
			totTimeAll{i,ii}(end+1) = totTime / (numTest + numDistract);
            tstTimeAll{i,ii}(end+1) = testTime / (numTest + numDistract);
            trnTimeAll{i,ii}(end+1) = trainTime / (numTrain + numDistract);
            trnTimeAllnoMean{i,ii}(end+1) = trainTime;
			
			custConf(isnan(custConf)) = 0;
			
			if exist('custConf', 'var') && ~isempty(custConf) && doCustConf(i) && sum(custConf)
				distMatrix(:,1) = 1-custConf;
			end
			
			curDist = [curDist; distMatrix];
			if size(distractDistMatrix,2) == 3
				if exist('distractCustConf', 'var') && ~isempty(custConf) && doCustConf(i)  && sum(custConf)
					distractDistMatrix(:,1) = 1-distractCustConf;
				end
				curDistractDist = [curDistractDist; distractDistMatrix];
            end
            
            %MTJSRC hack
            if ~isempty(strfind(accFile, 'mtjsrc'))% || ~isempty(strfind(accFile, 'LA-SVM'))
                distMatrix(:,1) = 1-distMatrix(:,1);
                if ~isempty(distractDistMatrix)
                    distractDistMatrix(:,1) = 1-distractDistMatrix(:,1);
                end
            end
			
            % Compute PR Curve
			[p,r,t] = fbCalcPRwithDistractors(distMatrix, distractDistMatrix, inc);
            
            [r,m,n]=unique(r);
            p = p(m);
            t = t(m);
			
			%hold on, plot(r,p,'k');
			
			pi = interp1(double(r(1:end-1)'),double(p(1:end-1)'),double(0:1/resolution:1));
			pi(isnan(pi)) = 0;
			PInd = [PInd; pi];
            PIndF = [PIndF; pi];
			WInd = [WInd; numTest];
			
			ti = interp1(double(r(1:end-1)'),double(t(1:end-1)'),double(0:1/resolution:1));
			ti(isnan(ti)) = 0;
			TInd = [TInd; ti];
			
			acc{ii} = [acc{ii} fbgAccuracy];
			testNum{ii} = [testNum{ii} numTest];
			trainNum{ii} = [trainNum{ii} numTrain];
        end
		
		totDist = [totDist; curDist];
		totDistractDist = [totDistractDist; curDistractDist];
    end
	
	r = 0:1/resolution:1;
	p = PInd;
    
	if min(size(p)) > 1%length(friends) > 1 || rep > 1
		p = repmat(WInd,1,length(r)).*PInd/sum(WInd);
		p = sum(p);
	end
	t = TInd;
	if min(size(t)) > 1%length(friends) > 1 || rep > 1
		t = repmat(WInd,1,length(r)).*TInd/sum(WInd);
		t = sum(t);
    end
    
    % Fix 0 value at the beginning
    if p(1) == 0 && r(1) == 0
        p(1) = [];
        r(1) = [];
    end
    
    if p(end) == 0 && r(end) == 1
        p(end) = [];
        r(end) = [];
    end
    
    % PR Values
	P{i,length(friends)+1} = p;
	R{i,length(friends)+1} = r;
	T{i,length(friends)+1} = t;
end



testTimeStr = sprintf('\nTest Time (ms/img)');
trainTimeStr = sprintf('\nTrain Time (ms)');
accStr = [sprintf('\nAccuracy ') '(%%)'];
apStr = [sprintf('\nAverage Precision ') '(%%)'];
recStr = [sprintf('\nRecall at %0.1f', 100*pvals) '%% Precision (%%)'];
for j = 1:length(friends)
    testTimeStr = [testTimeStr sprintf(',\t%d', friends(j))];
    trainTimeStr = [trainTimeStr sprintf(',\t%d', friends(j))];
    accStr = [accStr sprintf(',\t%d', friends(j))];
    apStr = [apStr sprintf(',\t%d', friends(j))];
    recStr = [recStr sprintf(',\t%d', friends(j))];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Average Precision, Accuracy, and Recall at High Precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apStr = [apStr sprintf('\n')];
accStr = [accStr sprintf('\n')];
recStr = [recStr sprintf('\n')];
for i = 1:length(names)
    accStr = [accStr sprintf('%s', names{i})];
    apStr = [apStr sprintf('%s', names{i})];
    
    % Compute Average Accuracy
	for j = 1:length(totAcc{i})
        accStr = [accStr sprintf(',\t%0.1f', mean(totAcc{i}{j}))];
    end
    
    % Compute Average Precision
    p = P{i,length(friends)+1};
    r = R{i,length(friends)+1};
    for j = 1 : size(p,1)
        apStr = [apStr sprintf(',\t%0.1f',sum(p(j,:)) ./ length(p(j,:))*100)];
    end
    
    % Compute Recall at High Precision
    rr = NaN;
    for j = 1:length(pvals)
        idx = find(P{i,end} > pvals(j));
        if ~isempty(idx)
            rr(j) = R{i,end}(idx(end))*100;
        end
    end
    recStr = [recStr sprintf('%s,\t%0.1f\n', names{i}, rr(1))];
    
    accStr = [accStr sprintf('\n')];
    apStr = [apStr sprintf('\n')];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Average Train and Test Time Per Image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    testTimeStr = [testTimeStr sprintf('\n')];
    trainTimeStr = [trainTimeStr sprintf('\n')];
	testTimesAvg = zeros(length(names), length(totAcc{1}));
	trainTimesAvg = zeros(length(names), length(totAcc{1}));
    for i = 1:length(names)
        out = [];
        testTimeStr = [testTimeStr sprintf('%s', names{i})];
        trainTimeStr = [trainTimeStr sprintf('%s', names{i})];
        for j = 1:length(friends)
			tstTime = mean(tstTimeAll{i,j})*1000;
            tstTimeStd = std(tstTimeAll{i,j})*1000;
			trnTime = mean(trnTimeAll{i,j});
            trnTime = max(trnTimeAllnoMean{i,j});
			testTimesAvg(i,j) = tstTime;
			trainTimesAvg(i,j) = trnTime;
            
            testTimeStr = [testTimeStr sprintf(',\t%0.1f', tstTime)];
            trainTimeStr = [trainTimeStr sprintf(',\t%0.1f', trnTime)];
        end
        testTimeStr = [testTimeStr sprintf('\n')];
        trainTimeStr = [trainTimeStr sprintf('\n')];
    end
catch
    testTimeStr = [testTimeStr sprintf('\n')];
    trainTimeStr = [trainTimeStr sprintf('\n')];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Computations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(trainTimeStr);
fprintf(testTimeStr);
fprintf(accStr);
fprintf(apStr);
fprintf(recStr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Computations to File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fName = fullfile(inpath,[graphFileName '.csv']);
fid = fopen(fName, 'w');
fprintf(fid, '%s\n%s\n%s\n%s\n%s', accStr, apStr, recStr, trainTimeStr, testTimeStr);
fclose(fid);