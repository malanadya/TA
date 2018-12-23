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

for jj = 1:length(options)
    
    opt = options{jj};

    imgPath = opt.dataset.imagePath;
    featPath = opt.dataset.featurePath;
    fbgFeatureLengths = [];

    % Initialize features
    featExist = 0; try, opt.features; featExist = 1; end;
    if featExist
        for i = 1:length(opt.features)
            try
                feat = opt.features{i};
                eval(sprintf('%s_init', feat.type));
            end
        end
    end

    for ii = 1:opt.dataset.repetitions
        mapCount = containers.Map();
        mapDistract = containers.Map();
        trainFiles = {};
        testFiles = {};
        distractFiles = {};
        
        
        fn = fullfile(featPath, sprintf('%s_%0.4d_%0.4d.mat', opt.dataset.name, opt.dataset.identities, ii-1)); % Output File
        % If output file exists, skip it.
        if exist(fn,'file'); fprintf('Skipping... %s_%0.4d_%0.4d.mat\n', opt.dataset.name, opt.dataset.identities, ii-1); continue; end

        if opt.dataset.repetitions > 1
            if ii == 1
                tmpImgPath = imgPath;
            end
            imgPath = fullfile(imgPath,sprintf('%06d-%06d',opt.dataset.identities,ii-1));
        end
            
        dTrain = dir(fullfile(imgPath, 'train*.jpg'));
        if length(dTrain)
            fprintf('Found explicit train/test/distract set in filenames, loading...\n');
            df = dTrain;
            for j = 1:length(df)
                trainFiles{end+1} = df(j).name;
            end
            df = dir(fullfile(imgPath, 'test*.jpg'));
            for j = 1:length(df)
                testFiles{end+1} = df(j).name;
            end
            df = dir(fullfile(imgPath, 'distract*.jpg'));
            for j = 1:length(df)
                distractFiles{end+1} = df(j).name;
            end
        else
            fprintf('Scanning directory and dividing up into train/test/distract...');
            df = dir(fullfile(imgPath, '*.jpg'));

            for j = 1:length(df)
                split = strsplit('-', df(j).name);
                uid = split{1};
                count = 0;
                try, count = mapCount(uid); end;
                mapCount(uid) = count + 1;
            end

            keyCount = keys(mapCount);
            valCount = cell2mat(values(mapCount));

            [sv,si] = sort(valCount, 'descend');

            for k = 1:opt.dataset.identities
                uid = keyCount(si(k)); 
                uid = uid{1};

                % Get all photos for this user
                dUser = dir(fullfile(imgPath, sprintf('%s-*.jpg', uid)));

                % Add faces from the user to the train set
                len = length(dUser);
                r = randperm(len);
                for j = 1:ceil(len*opt.dataset.trainPercent/100)
                    fn = dUser(r(j)).name;
                    trainFiles{end+1} = fn;
                    mapDistract(fn) = 1;
                end

                % Now add faces to the test and create the distract set        
                for j = ceil(len*opt.dataset.trainPercent/100)+1:len
                    fn = dUser(r(j)).name;
                    testFiles{end+1} = fn;
                    mapDistract(fn) = 1;
                end
            end

            % Should we create a distractor set too?
            if opt.dataset.enableDistract

                % If we want the distract set to be a set fraction of the test
                % files, then select them randomly
                if opt.dataset.forceDistractFraction > 0
                    r = randperm(length(df));
                    ctr = 1;
                    for j = 1:length(testFiles)*opt.dataset.forceDistractFraction

                        fn = df(r(ctr)).name;
                        found = 0;
                        try, found = mapDistract(fn); end
                        while ~found
                            ctr = ctr + 1;
                            if ctr > length(df)
                                found = -1;
                                break;
                            end
                            fn = df(r(ctr)).name;
                            found = 0;
                            try, found = mapDistract(fn); end
                        end

                        if found < 0
                            break;
                        end

                        distractFiles{end+1} = fn;
                    end
                else
                    % Select actual distractors in the background of test photos
                    for j = 1:length(testFiles)
                        fn = testFiles{j};

                        % See who else was in the photo and add them to distract set
                        split = strsplit('-', fn);
                        pid = split{2};
                        dPhoto = dir(fullfile(imgPath, sprintf('*-%s', pid)));
                        for m = 1:length(dPhoto)
                            found = 0;
                            fn = dPhoto(m).name;
                            try, found = mapDistract(fn); end
                            if ~found
                                mapDistract(fn) = 1;
                                distractFiles{end+1} = fn;
                            end
                        end
                    end
                end
            end
        end

        % OK now we have trainFiles, testFiles, and distractFiles
        % Let's load stuff in

        precision = 'double';
        numDimsPCA = 0;
        maxMemGB = 0.5;
        try, numDimsPCA = opt.dataset.pca.numDims; end
        try, maxMemGB = opt.dataset.pca.maxMemGB; end
        try, precision = opt.dataset.precision; end;

        numTrain = length(trainFiles);
        numTest = length(testFiles);
        numDistract = length(distractFiles);

        firstImg = imread(fullfile(imgPath, trainFiles{1}));
        img = firstImg;
        fbCreateDataset_runfeat;
        firstVec = finalOutVec;

        if length(trainFiles) && numDimsPCA && opt.dataset.pca.maxMemGB

            fprintf('\nCalculating PCA...');

            finalVec = firstVec;
            currentTotalMem = numTrain*length(finalVec)*4/1024^3;
            skip = max([1 floor(currentTotalMem / maxMemGB)]);
            newNumTrain = floor(numTrain / skip * 0.99) - 1; % be a bit conservative, scale back

            fbgTrainImgs = 0;

            ctrTrain = 0;
            fprintf('%0.6d/%0.6d', 0, 0);
            for j = 1:skip:numTrain
                img = imread(fullfile(imgPath, trainFiles{j}));
                fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', j, newNumTrain);

                fbCreateDataset_runfeat;

                finalVec = finalOutVec;

                if size(fbgTrainImgs,1) ~= length(finalVec)
                    assert(ctrTrain <= 0);
                    fbgTrainImgs = zeros([length(finalVec), newNumTrain], precision);
                end

                ctrTrain = ctrTrain + 1;
                fbgTrainImgs(:,ctrTrain) = finalVec;
                if ctrTrain >= newNumTrain
                    break;
                end
            end

            assert(ctrTrain == newNumTrain)
            assert(~sum(isnan(fbgTrainImgs(:))))

            % Pre-calculate PCA because we'll be using this a lot
            fbgEigenV = [];
            fbgSingVal = [];
            pcaTime = [];
            data = fbgTrainImgs;
            fbgAvgFace = mean(fbgTrainImgs,2);

            for i = 1:size(data, 2)
                data(:,i) = data(:,i) - fbgAvgFace;
            end

            % Do PCA using SVD (Singular Value Decomposition)
            try
                tic
                [fbgEigenV,fbgSingVal] = svd(data,'econ');
                fbgSingVal = diag(fbgSingVal);
                pcaTime = toc;
            catch
                fprintf('Could not do pca');
                clear;
                abort(0);
            end
            clear data;

            fbgEigenV = fbgEigenV(:,1:min([opt.dataset.pca.numDims size(fbgEigenV,1) size(fbgEigenV,2)]));

            fbgTrainImgs = zeros(size(fbgEigenV,2), numTrain, precision);
            fbgTestImgs = zeros(size(fbgEigenV,2), numTest, precision);
            fbgDistractImgs = zeros(size(fbgEigenV,2), numDistract, precision);
            fbgTrainIds = zeros(numTrain,1);
            fbgTestIds = zeros(numTest,1);
            fbgDistractIds = zeros(numDistract,1);
        else
            fbgTrainImgs = zeros(length(firstVec), numTrain, precision);
            fbgTestImgs = zeros(length(firstVec), numTest, precision);
            fbgDistractImgs = zeros(length(firstVec), numDistract, precision);
            fbgTrainIds = zeros(numTrain,1);
            fbgTestIds = zeros(numTest,1);
            fbgDistractIds = zeros(numDistract,1);
        end

        uidCtr = 0;
        mapUids = containers.Map();

        % Now actually load stuff in
        fprintf('\nLoading training...');
        fprintf('%0.6d/%0.6d', 0, 0);
        for i = 1:length(trainFiles)
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, numTrain);
            img = imread(fullfile(imgPath, trainFiles{i}));
            %split = sscanf(trainFiles{i}, '%f-%f.jpg');
            split = strsplit('-', trainFiles{i});
            uid = split{1};
            uid = strrep(uid, 'train_', '');
            uid = strrep(uid, 'test_', '');
            uid = strrep(uid, 'distract_', '');
            try, u = mapUids(uid); catch, uidCtr = uidCtr + 1; u = uidCtr; mapUids(uid) = uidCtr; end
            fbCreateDataset_runfeat;
            finalVec = finalOutVec;
            try, finalVec = fbgEigenV'*(finalOutVec - fbgAvgFace); end
            fbgTrainImgs(:,i) = finalVec;
            fbgTrainIds(i) = u;
        end

        fprintf('\nLoading test...');
        fprintf('%0.6d/%0.6d', 0, 0);
        for i = 1:length(testFiles)
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, numTest);
            img = imread(fullfile(imgPath, testFiles{i}));
            %split = sscanf(testFiles{i}, '%f-%f.jpg');
            split = strsplit('-', testFiles{i});
            uid = split{1};
            uid = strrep(uid, 'train_', '');
            uid = strrep(uid, 'test_', '');
            uid = strrep(uid, 'distract_', '');
            try, u = mapUids(uid); catch, uidCtr = uidCtr + 1; u = uidCtr; mapUids(uid) = uidCtr; end
            fbCreateDataset_runfeat;
            finalVec = finalOutVec;
            try, finalVec = fbgEigenV'*(finalOutVec - fbgAvgFace); end
            fbgTestImgs(:,i) = finalVec;
            fbgTestIds(i) = u;%split(1);
        end

        fprintf('\nLoading distract...');
        fprintf('%0.6d/%0.6d', 0, 0);
        for i = 1:length(distractFiles)
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b%0.6d/%0.6d', i, numDistract);
            img = imread(fullfile(imgPath, distractFiles{i}));
            %split = sscanf(distractFiles{i}, '%f-%f.jpg');
            split = strsplit('-', distractFiles{i});
            uid = split{1};
            uid = strrep(uid, 'train_', '');
            uid = strrep(uid, 'test_', '');
            uid = strrep(uid, 'distract_', '');
            try, u = mapUids(uid); catch, uidCtr = uidCtr + 1; u = uidCtr; mapUids(uid) = uidCtr; end
            fbCreateDataset_runfeat;
            finalVec = finalOutVec;
            try, finalVec = fbgEigenV'*(finalOutVec - fbgAvgFace); end
            fbgDistractImgs(:,i) = finalVec;
            fbgDistractIds(i) = u;%split(1);
        end
        
        if ~exist(featPath,'dir'); mkdir(featPath); end
        fprintf('\nSaving dataset to %s...\n', fn);
        save(fn, 'fbgTrainImgs', 'fbgTrainIds', 'fbgTestImgs', 'fbgTestIds', 'fbgDistractImgs', 'fbgDistractIds', 'opt');

        fprintf('\n');
        
        if opt.dataset.repetitions > 1
            imgPath = tmpImgPath;
        end
    end
end