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

clc; clear; close all;
addpath(genpath('.'));

fprintf('Face Recognition Toolbox (FRT)\n');
fprintf('For non-commercial use.\n');
fprintf('by Enrique G. Ortiz and Brianc C. Becker');

% doPF83: Specifies which options to use.
% For 0 = Face Recognition for Web-Scale Datasets
% For 1 = Evaluating Open-Universe Face Identification on the Web
doPF83 = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n*** Creating Dataset ***\n');
featureOptions;
if doPF83; datasetOptionsPF83LFW; else datasetOptions; end
fbCreateDataset;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n*** Running Experiments ***\n');
if doPF83; experimentOptionsPF83LFW; else experimentOptions; end
fbRunExperiments


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n*** Reporting Results ***\n');
clear; close all;
if doPF83; reportOptionsPF83LFW; else reportOptions; end
fbReportResults;