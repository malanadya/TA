
% cleanmex

cd util
mex('-largeArrayDims myContrast.cc');
cd ../

cd algsrc
mex('-largeArrayDims mexArrangeLinear.cc');
mex('-largeArrayDims mexAssignWeights.cc');
mex('-largeArrayDims mexColumnNormalize.cc');
mex('-largeArrayDims mexSumOverScales.cc');
mex('-largeArrayDims mexVectorToMap.cc');
cd ../

cd saltoolbox/
mex('-largeArrayDims mySubsample.cc');
mex('-largeArrayDims mexLocalMaximaGBVS.cc');
cd ../
