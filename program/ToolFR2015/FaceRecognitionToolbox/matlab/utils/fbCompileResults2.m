%try
    try, opt.dataset.start; catch, opt.dataset.start = 0; end
    try, opt.dataset.finish; catch, opt.dataset.finish = 1; end
    friendlyName = '';
    try, friendlyName = opt.algorithm.friendlyName; end

	%outdir = fullfile(opt.results.path, ['fbacc_' opt.dataset.name '_' opt.algorithm.name '_' opt.results.name '/']);
    outdir = fullfile(opt.results.path, ['fbacc_' opt.dataset.name '_' friendlyName '_' opt.results.name '/']);
	
	acc = cell(length(opt.dataset.identities),1);
	testNum = cell(length(opt.dataset.identities),1);
	trainNum = cell(length(opt.dataset.identities),1);
	for ii = 1:length(opt.dataset.identities)
		for jj = opt.dataset.start:opt.dataset.repetitions(ii)-opt.dataset.finish
			rep = jj;
			baseName = sprintf([opt.dataset.name  '_%0.4d_%0.4d'], opt.dataset.identities(ii), rep);
			%accFile = [outdir baseName opt.dataset.name '_acc.mat'];
            accFile = fullfile(outdir,[baseName '_acc.mat']);
			clear fbgAccuracy numTest numTrain;
			load(accFile);
			acc{ii} = [acc{ii} fbgAccuracy];
			testNum{ii} = [testNum{ii} numTest];
			trainNum{ii} = [trainNum{ii} numTrain];
		end
	end
% catch
% 	fprintf('Not quite done yet...%s\n', accFile);
% 	return;
% end

finAccFile = fullfile(outdir,'acc.mat');
save(finAccFile, 'acc', 'trainNum', 'testNum', 'opt');
fprintf('Done! Saved %s\n', finAccFile);