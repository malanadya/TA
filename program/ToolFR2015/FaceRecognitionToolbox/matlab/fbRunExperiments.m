%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  MATLAB Face Recognition Toolbox v1.0
%       Copyright (C) Jan 2014 Enrique G. Ortiz and Brian C. Becker
%                  enriquegortiz.com & briancbecker.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This toolbox was created to foster research in the face recognition
% community. It implements our new algorithm LASRC as well as others: NN, 
% SVM, SVM-KNN, SRC, MTJSRC, LLC, KNN-SRC, LRC, L2, and CRC_RLS. If you use
% our algorithm or toolbox please reference:
%
%  1) Face Recognition for Web-Scale Datasets
%  E. G. Ortiz and B. C. Becker, "Face Recognition for Web-Scale Datasets."
%  ELSEVIER Computer Vision and Image Understanding (CVIU), Sept. 2013.
%  http://goo.gl/8YBjCf
%
%  2) Evaluating Open-Universe Face Identification on the Web
%  B. C. Becker and E. G. Ortiz, "Evaluating Open-Universe Face
%  Identification on the Web." IEEE Conferece on Computer Vision and
%  Pattern Recognition - Workshop on Analysis and Modeling of Faces and 
%  Gestures, Jun. 2013.
%  http://goo.gl/y60QS6
% 
% If you use any of the other algorithms also cite the corresponding
% publications. 
%
% This toolbox performs all of the following tasks:
%
% 1) fbCreateFaceDatasets: Generates datasets from raw images download from 
%    Facebook or any other source by extracting features and creating 
%    correct data splits for input to experimental stage.
% 2) fbRunExperiments: Runs all specified algorithms on data generated in 
%    the previous stage.
% 3) fbReportResults: Generates graphs and tables for specified algorithms 
%    run during previous stage.
%
% Remember to modify the option files for each stage (look inside scripts
% for exact names in the options directory).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For more information, see http://enriquegortiz.com/fbfaces.
%
% Contact: Enrique G. Ortiz (ortizeg@gmail.com)
%          Brian C. Becker (brian@briancbecker.com).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('workFile','var'); delete(workFile); end

for o = 1:length(options)
	opt = options{o};
    fbgRows = [];
    fbgCols = [];
    
    try, opt.dataset.start; catch, opt.dataset.start = 0; end
    try, opt.dataset.finish; catch, opt.dataset.finish = 1; end
    friendlyName = '';
    try, friendlyName = opt.algorithm.friendlyName; end

	outdir = fullfile(opt.results.path, ['fbacc_' opt.dataset.name '_' friendlyName '_' opt.results.name '/']);
	if ~exist(opt.results.path, 'dir'); mkdir(opt.results.path); end
	if ~exist(outdir, 'dir'); mkdir(outdir); end
	
	for i = 1:1e3
		fn = sprintf(['%soptions%0.4d.mat'], outdir, i);
		if ~exist(fn, 'file')
			save(fn, 'opt');
			break;
		end
	end

	acc = cell(length(opt.dataset.identities),1);
	testNum = cell(length(opt.dataset.identities),1);
	trainNum = cell(length(opt.dataset.identities),1);
	for ii = 1 : length(opt.dataset.identities)
		for jj = opt.dataset.start:opt.dataset.repetitions(ii)-opt.dataset.finish
            rep = jj;
			limFriends = opt.dataset.identities(ii);
			baseName = sprintf([opt.dataset.name  '_%0.4d_%0.4d'], opt.dataset.identities(ii), rep);
            filename = fullfile(opt.dataset.featurePath, [baseName '.mat']);
			if isempty(dir(filename))
                fprintf('Errror: Could not load %s!\n', filename);
                return;
			end

			ctr = 0;
			%accFile = [outdir baseName opt.dataset.name '_acc.mat'];
			%caccFile = [outdir baseName opt.dataset.name '_cacc.mat'];
            accFile = fullfile(outdir,[baseName '_acc.mat']);
            caccFile = fullfile(outdir,[baseName '_cacc.mat']);
			fprintf('[%d/%d %d %d] %s: %s (%s)', o, length(options), opt.dataset.identities(ii), rep, friendlyName, opt.results.name, baseName);
			workFile = [outdir baseName opt.dataset.name '_working.mat'];

			if opt.skipDone && (exist(accFile, 'file') || exist(workFile, 'file'))
				fprintf('Skipping\n');
				continue;
			end
			save(workFile, 'ctr');            

            clear fbgTrainImgs fbgTrainIds fbgTestImgs fbgTestIds fbgDistractImgs fbgDistractIds;
            clear trainWeights testWeights;
            clear extraInfo;
            
            % Do training
            load(filename, 'fbgTrainIds', 'fbgTrainImgs');
            fbgTrainIds = fbgTrainIds(:);
            numTrain = length(fbgTrainIds);
            testSizes = [];
            extraInfo = {};
            
            tic
            fprintf('\nTrain\n');
			fbgAvgFace = mean(fbgTrainImgs,2);
            for i = 1:size(fbgTrainImgs, 2)
                fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
            end
			truncDims = 0; try, truncDims = opt.dataset.truncDims; end
			if truncDims && size(fbgTrainImgs,1) > truncDims, fbgTrainImgs = fbgTrainImgs(1:truncDims,:); end
			eval(sprintf('train_%s', opt.algorithm.name));
			trainTime = toc;

            % Test distractors first
            clear fbgTestImgs fbgTestIds;
            load(filename,'fbgDistractImgs','fbgDistractIds');
            fbgDistractIds = fbgDistractIds(:);
            fbgTestImgs = fbgDistractImgs;
            fbgTestIds = fbgDistractIds;

            % Check if a Distractor Set Even Exists
            if size(fbgTestImgs,2) ~= 0    
                for i = 1:size(fbgTestImgs, 2)
                    fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
                end
				if truncDims && size(fbgTestImgs,1) > truncDims, fbgTestImgs = fbgTestImgs(1:truncDims,:); end
                trainWeights = fbgTrainImgs;
                testWeights = fbgTestImgs;
                numDistract = length(fbgTestIds);
                fprintf('Distract');
                tic
                clearLibsvm = 0;
                custConf = [];
                cdistMatrix = [];
                eval(sprintf('test_%s', opt.algorithm.name));
                distractDistMatrix = distMatrix;
                distractCDistMatrix = cdistMatrix;
                distractCustConf = custConf;
                distractTime = toc;
                fprintf('\n');
            else
                tic
                distractTime = toc;
                distractDistMatrix = [];
                distractCDistMatrix = [];
                distractCustConf = 0;
                numDistract = 0;
            end
            
            fbgDistractIds = fbgTestIds;

			% Test Non-distractors
            clear fbgTestImgs fbgTestIds;
            load(filename,'fbgTestImgs','fbgTestIds');
            fbgTestIds = fbgTestIds(:);
			

            numTest = length(fbgTestIds);
            for i = 1:size(fbgTestImgs, 2)
                fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
            end
			if truncDims && size(fbgTestImgs,1) > truncDims, fbgTestImgs = fbgTestImgs(1:truncDims,:); end
            testWeights = fbgTestImgs;
            fprintf('Non-distract');
            tic
			clearLibsvm = 1;
			custConf = [];
			cdistMatrix = [];
			eval(sprintf('test_%s', opt.algorithm.name));
			testTime = toc + distractTime;
            fprintf('\n');
            
            clear Ainv;

			delete(workFile);
			totTime = trainTime+testTime;
			fprintf('\b\n |-> Accuracy (%d %d %d): %0.2f%% (%0.2fs %0.2fs/img)\n', numTrain, numTest, numDistract, fbgAccuracy, totTime, totTime/(numTest + numDistract));
            
            if ~exist('pcaTime', 'var'), pcaTime = []; end
            save(accFile, 'fbgAccuracy', 'numTrain', 'numTest', 'numDistract', 'distMatrix', 'distractDistMatrix', 'testSizes', 'totTime', 'trainTime', 'testTime', 'distractTime', 'pcaTime');
			save(caccFile, 'fbgAccuracy', 'numTrain', 'numTest', 'numDistract', 'distMatrix', 'distractDistMatrix', 'testSizes', 'cdistMatrix', 'distractCDistMatrix', 'distractCustConf', 'custConf', 'totTime', 'trainTime', 'testTime', 'distractTime', 'pcaTime', 'extraInfo');
		end
	end

	fprintf('Compiling results...\n');
	fbCompileResults2;
	fprintf('\n');
end

fprintf('Compiling all results...\n');
for o = 1:length(options)
	opt = options{o};
	
	fbCompileResults2;
end