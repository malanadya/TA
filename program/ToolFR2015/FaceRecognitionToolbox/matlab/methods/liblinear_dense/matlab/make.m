% This make.m is used under Windows

mex -O -largeArrayDims -c ..\blas\*.c -outdir ..\blas -D_DENSE_REP
mex -O -largeArrayDims -c ..\linear.cpp -D_DENSE_REP
mex -O -largeArrayDims -c ..\tron.cpp -D_DENSE_REP
mex -O -largeArrayDims -c linear_model_matlab.c -I..\ -D_DENSE_REP
mex -O -largeArrayDims train.c -I..\ tron.obj linear.obj linear_model_matlab.obj ..\blas\*.obj -D_DENSE_REP
mex -O -largeArrayDims predict.c -I..\ tron.obj linear.obj linear_model_matlab.obj ..\blas\*.obj -D_DENSE_REP
mex -O -largeArrayDims libsvmread.c -D_DENSE_REP
mex -O -largeArrayDims libsvmwrite.c -D_DENSE_REP

movefile('train.mexw64', 'train_liblinear_dense.mexw64');
movefile('predict.mexw64', 'predict_liblinear_dense.mexw64');