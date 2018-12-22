%compile all the binaries for your platform
fprintf('mex-compiling : linear interpolation..\n');
mex mex_linear_interpolate.cc

fprintf('mex-compiling : weighted kernel sampling ..\n');
mex mex_sample_weighted_kernel.cc

fprintf('mex-compiling : weighted intersection kernel sampling..\n');
mex mex_sample_weighted_int_kernel.cc