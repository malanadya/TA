%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> make.m: Makes libsvm MEX interface for
% Matlab. The original libsvm MEX suffers from large memory overhead,
% passing the model back and forth between C and Matlab. This is a slightly
% modified version that offers more options to reduce the overhead of
% passing data back and forth. It also reduces replicated data. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Authors:                           Brian C. Becker @ www.BrianCBecker.com
% Copyright (c) 2007-2008          Enrique G. Ortiz @ www.EnriqueGOrtiz.com
%
% License: You are free to use this code for academic and non-commercial
% use, provided you reference the following paper in your work.
%
% Becker, B.C., Ortiz, E.G., "Evaluation of Face Recognition Techniques for 
% Application to Facebook," in Proceedings of the 8th IEEE International
% Automatic Face and Gesture Recognition Conference, 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This make.m is used under Windows
LIBSVM_DEBUG = 0;

% Unload libsvm mex dll so we can (re)compile it
clear libsvm

if LIBSVM_DEBUG
	mex -O -g -c -largeArrayDims svm.cpp
	mex -O -g -c -largeArrayDims svm_model_matlab.c
	mex -O -g -largeArrayDims libsvm.c svm.obj svm_model_matlab.obj
else
	mex -O -c -largeArrayDims svm.cpp
	mex -O -c -largeArrayDims svm_model_matlab.c
	mex -O -largeArrayDims libsvm.c svm.obj svm_model_matlab.obj	
end

% This only keeps the folder structure organized
files = {'svm.obj', 'svm_model_matlab.mexw32.pdb', 'svm.mexw32.pdb', 'libsvm.mexw32.pdb', 'svm_model_matlab.obj', 'libsvm.ilk', 'svm.mexw64.pdb', 'libsvm.mexw64.pdb', 'svm_model_matlab.mexw64.pdb'};
for i = 1:length(files)
	if exist(['./' files{i}], 'file')
		if exist([files{i}])
			delete([files{i}]);
        end
	end
end
