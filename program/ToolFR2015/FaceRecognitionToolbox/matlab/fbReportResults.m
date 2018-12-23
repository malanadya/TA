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

graphFriends = 0;
start = 0; finish = 1;
extraSize = 6;
small = 1;
markerSize = 6;
otherSize = 12+extraSize;
axisSize = 15+extraSize;
dontDoublePlot = 1;
outTexAcc = 1;

friends = opt.results.identities;
repetitions = opt.results.repetitions;
inpath = opt.results.path;
start = 0;
finish = repetitions;
try, start = opt.results.start; end
try, finish = opt.results.finish; end
graphFileName = opt.results.fileName;

if ~exist('doCustConf', 'var')
    doCustConf = zeros(length(opt.results.algorithms),1);
end

datasetAlgoName = cell(length(opt.results.algorithms), 3);
for i = 1:length(opt.results.algorithms)
    datasetAlgoName{i,1} = '';
    datasetAlgoName{i,2} = opt.results.algorithms{i}{2};
    datasetAlgoName{i,3} = opt.results.algorithms{i}{1};
    %datasetAlgoName{i} = {'', opt.results.results{i}{2}, opt.results.results{i}{1}};
    try, doCustConf(i) = opt.results.algorithms{i}{3}; end
end



algos = datasetAlgoName(:,2);
names = datasetAlgoName(:,3);
datasets = datasetAlgoName(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Accuracy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dirPrefix = {};
totAcc = cell(length(algos),1);
totTrain = cell(length(algos),1);
totTest = cell(length(algos),1);
totTot = cell(length(algos),1);
for i = 1:length(algos)
	clear acc trainNum testNum;
% 	filename = [inpath 'acc_' datasets{i} '_' algos{i} '.mat'];
    filename = fullfile(inpath,algos{i},'acc.mat');
	
	% Check if this is a directory
	dirPrefix{i} = [];
	if exist([inpath algos{i}], 'dir')
		d = dir([inpath algos{i} '/acc*.mat']);
		if length(d) == 1
			filename = [inpath algos{i} '/' d(1).name];
			dirPrefix{i} = d(1).name(5:end-4);
		end
	end
	
    load(filename);
	
	% Reverse accuracies in the case we did fliplr(friends) to do 512 first
	if length(acc{end}) > length(acc{1})
		for k = 1:length(acc)
			nacc{k} = acc{end-k+1};
			ntestNum{k} = testNum{end-k+1};
			ntrainNum{k} = trainNum{end-k+1};
		end
		acc = nacc';
		testNum = ntestNum';
		trainNum = ntrainNum';
	end
	if length(acc) == 9
		acc = {acc{end-4} acc{end-2} acc{end}}';
		acc{1} = acc{1}(1:8);
		acc{2} = acc{2}(1:4);
		acc{3} = acc{3}(1:2);
		
		testNum = {testNum{end-4} testNum{end-2} testNum{end}}';
		testNum{1} = testNum{1}(1:8);
		testNum{2} = testNum{2}(1:4);
		testNum{3} = testNum{3}(1:2);
		
		trainNum = {trainNum{end-4} trainNum{end-2} trainNum{end}}';
		trainNum{1} = trainNum{1}(1:8);
		trainNum{2} = trainNum{2}(1:4);
		trainNum{3} = trainNum{3}(1:2);
	end
    totAcc{i} = acc;
    totTrain{i} = trainNum;
    totTest{i} = testNum;
    tot = trainNum;
    for j = 1:length(testNum)
        tot{j} = tot{j} + testNum{j};
    end
    totTot{i} = tot;
end

accMean = zeros(length(algos), length(friends));
accStd = zeros(length(algos), length(friends));
accVar = zeros(length(algos), length(friends));
p = cell(length(algos), 1);
q = cell(length(algos), 1);
ds = cell(length(algos), 1);
n = cell(length(algos), 1);
for i = 1:length(algos)
    allRight = [];
    allWrong = [];
    for j = 1:length(friends)
        test = totTest{i}{j};
        acc = totAcc{i}{j} ./ 100;
        right = int32(test .* acc);
        wrong = int32(test .* (1 - acc));
        accMean(i,j) = 100 * sum(right) / sum(right + wrong);
        accStd(i,j) = std(acc);
        allRight = [allRight right];
        allWrong = [allWrong wrong];
    end
    n{i} = sum(allRight + allWrong);
    p{i} = sum(allRight) / n{i};
    q{i} = 1 - p{i};
    ds{i} = sqrt(p{i}*q{i});
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Time and PR Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acc = cell(length(friends),1);
testNum = cell(length(friends),1);
trainNum = cell(length(friends),1);
P = cell(length(algos), length(friends)+1);
Ps = cell(length(algos), length(friends)+1);
R = cell(length(algos), length(friends)+1);


combinePR;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Accuracy Graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Position', [0 0 1200   400]);
movegui(f);

if size(accMean,2) == 1
    accMean = [accMean zeros(size(accMean))];
end
bar(accMean')
leg = names;
grid on
%leg{end+1} = 'Chance';
legend(leg, 'Location', 'EastOutside');
ylim([0 100]);
xlabel('Dataset Size (Friends)', 'FontSize', axisSize, 'FontWeight', 'bold');
ylabel('Accuracy (%)', 'FontSize', axisSize, 'FontWeight', 'bold');
xlabels = {};
for j = 1:length(friends)
    xlabels{end+1} = sprintf('%d', friends(j));
end
set(gca,'XTickLabel', xlabels, 'FontSize', otherSize)
set(gca,'XTick',[1:length(xlabels)]);
set(gcf, 'PaperPositionMode', 'auto');
drawnow

filename = [inpath graphFileName '_acc.eps'];
print(gcf, '-depsc', filename);
fixfilename = [inpath graphFileName '_acc.eps'];
fixPSlinestyle(filename,fixfilename);
filename = [inpath graphFileName '_acc.jpg'];
print(gcf, '-djpeg', filename);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test Time Graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Position', [0 0 1200   400]);
movegui(f,'center');
if size(testTimesAvg,2) == 1
	testTimesAvg = [testTimesAvg zeros(size(testTimesAvg))];
end
bar(testTimesAvg')
leg = names;
grid on
%leg{end+1} = 'Chance';
legend(leg, 'Location', 'EastOutside');
xlabel('Dataset Size (Friends)', 'FontSize', axisSize, 'FontWeight', 'bold');
ylabel('Test Times (s/img)', 'FontSize', axisSize, 'FontWeight', 'bold');
xlabels = {};
for j = 1:length(friends)
	xlabels{end+1} = sprintf('%d', friends(j));
end
%xlabels = {'32', '128', '512'};
set(gca,'XTickLabel', xlabels, 'FontSize', otherSize)
set(gca,'XTick',[1:length(xlabels)]);

set(gcf, 'PaperPositionMode', 'auto');
drawnow

filename = [inpath graphFileName '_tst.eps'];
print(gcf, '-depsc', filename);
fixfilename = [inpath graphFileName '_tst.eps'];
fixPSlinestyle(filename,fixfilename);
filename = [inpath graphFileName '_tst.jpg'];
print(gcf, '-djpeg', filename);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PR Graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Position', [0  0   800   600]);
movegui(f);
hold on
axis([0 1 0 1]);
leg = {};

percentScale = 100;
colors = [
    255 0 0;        % Red
	011 204 051;    % Medium green
    0 0 255;        % Blue
    221 113 219;    % Purple
	0 201 203;      % Cyan
	255 162 0       % Orange
	255 0 0;        % Red again
    209 207 32;     % Green yellow
    0 201 203;      % Cyan
    153 0 0;
    153 0 0;
    85 85 85;       % Dark Grey
    255 162 0       % Orange
	
    255 0 0;        % Red
	011 204 051;    % Medium green
    0 0 255;        % Blue
    221 113 219;    % Purple
	153 0 0;
	0 201 203;      % Cyan
	255 162 0       % Orange
	255 0 0;        % Red again
    209 207 32;     % Green yellow
    0 201 203;      % Cyan
    85 85 85;       % Dark Grey
    255 162 0       % Orange

	];
colors = [colors; flipud(colors)];

markers = {'+', 's', 'd', 'o', 'p', 'x', 's', 'd', 'o', '^', '^', 'p', 'x', '+', 's', 'd', 'o', '^', 'p', 'x', 's', 'd', 'o', '^', 'p', 'x', ...
	'+', 's', 'd', 'o', '^', 'p', 'x', 's', 'd', 'o', '^', 'p', 'x', '+', 's', 'd', 'o', '^', 'p', 'x', 's', 'd', 'o', '^', 'p', 'x'};
style = {
	'--', '--', '--', '--', '--', '-', '-', '-', ... 
	'-', '-', '-.', '-.', '-.', '-.', '-.', '-.', ...
	'-', '-', '-', '-', '-', '-', '-', '-', ...
	'-', '-', '-', '--', '-', '--', '-', '-', ... 
	'-.', '-.', '-.', '-.', '-.', '-.', '-.', '-.', ...
	'-', '-', '-', '-', '-', '-', '-', '-', ...
	};


if exist('addgpsr', 'var') && addgpsr
    colors = [colors(1:3,:); 0 0 0; colors(4:end,:)];
    style = [style(1:3), '-.', style(4:end)];
    markers = [markers(1:3), '*', markers(4:end)];
end

if exist('addsvm', 'var') && addsvm
    colors = [colors(1:1,:); 128 128 128; colors(2:end,:)];
    style = [style(1:1), ':', style(2:end)];
    markers = [markers(1:1), '+', markers(2:end)];
end

if exist('addomp', 'var') && addgpsr
    colors = [colors(1:7,:); 218 179 255; colors(8:end,:)];
    style = [style(1:7), '--', style(8:end)];
    markers = [markers(1:7), 's', markers(8:end)];
end

colors = colors ./ max(colors(:));

leg = {};
for i = 1:length(algos)
    plot(r*percentScale+1000,p*percentScale, style{i}, 'Color', colors(i,:), 'LineWidth', 2*small, 'Marker', markers{i}, 'MarkerSize', markerSize+4*small);
	leg{end+1} = sprintf('%s', names{i});
end
for i = 1:length(algos)
	p = P{i,length(friends)+1}*percentScale;
	r = R{i,length(friends)+1}*percentScale;
	len10 = floor(length(r)/10) + floor(rand(1)*20);
	idx = [20+floor(rand(1)*100):len10:length(r)];
	plot(r,p, style{i}, 'Color', colors(i,:), 'LineWidth', 2*small, 'MarkerSize', markerSize);
	plot(r(idx),p(idx), markers{i}, 'Color', colors(i,:), 'LineWidth', 2*small, 'Marker', markers{i}, 'MarkerSize', markerSize+3*small);
end

axis([0 1 0 1]*percentScale)
legend(leg, 'FontSize', axisSize-2-2, 'Location', 'SouthWest');
xlabel('Recall', 'FontSize', axisSize, 'FontWeight', 'bold');
ylabel('Precision', 'FontSize', axisSize, 'FontWeight', 'bold');

set(gca,'XTick',[0:10:100]);
set(gca,'XTickLabel', {'0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'}, 'FontSize', otherSize)
set(gca,'YTick',[0:10:100]);
set(gca,'YTickLabel', {'0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'}, 'FontSize', otherSize)
xlabel('Recall (%)', 'FontSize', axisSize, 'FontWeight', 'bold');
ylabel('Precision (%)', 'FontSize', axisSize, 'FontWeight', 'bold');


grid on
set(gca, 'Box', 'on')
set(gca,'Xcolor',[0 0 0])
set(gca,'Ycolor',[0 0 0])
if ~dontDoublePlot
	c_axes = copyobj(gca,gcf);
	set(c_axes, 'color', 'none', 'xcolor', 'k', 'xgrid', 'off', 'ycolor','k', 'ygrid','off');
end

set(gcf, 'PaperPositionMode', 'auto');
drawnow

filename = [inpath graphFileName '_pr.eps'];
print(gcf, '-depsc', filename);
fixfilename = [inpath graphFileName '_pr.eps'];
fixPSlinestyle(filename,fixfilename);
filename = [inpath graphFileName '_pr.jpg'];
print(gcf, '-djpeg', filename);