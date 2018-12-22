# This Makefile is used under Linux

# point this to your matlab directory
MATLABDIR ?= /Applications/MATLAB_R2009b.app

CXX ?= g++
CFLAGS = -Wall -Wconversion -O3 -fPIC -I$(MATLABDIR)/extern/include

MEX = $(MATLABDIR)/bin/mex
MEX_OPTION = CC\#$(CXX) CXX\#$(CXX) CFLAGS\#"$(CFLAGS)" CXXFLAGS\#"$(CFLAGS)"


# comment the following line if you use MATLAB on 32-bit computer
MEX_OPTION += -largeArrayDims
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)



all:	matlab

matlab:	binary

binary: mex_linear_interpolate.$(MEX_EXT) mex_sample_weighted_int_kernel.$(MEX_EXT) mex_sample_weighted_kernel.$(MEX_EXT) 

mex_linear_interpolate.$(MEX_EXT):     mex_linear_interpolate.cc
	$(MEX) $(MEX_OPTION) mex_linear_interpolate.cc

mex_sample_weighted_kernel.$(MEX_EXT):       mex_sample_weighted_kernel.cc
	$(MEX) $(MEX_OPTION) mex_sample_weighted_kernel.cc

mex_sample_weighted_int_kernel.$(MEX_EXT):       mex_sample_weighted_int_kernel.cc
	$(MEX) $(MEX_OPTION) mex_sample_weighted_int_kernel.cc

clean:
	rm -f *~ *.o *.mex* *.obj
