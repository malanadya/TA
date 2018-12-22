# * caltech-4 *

P_IMAGES := $(HOME)/data/caltech-4
P_SIFTS  := $(HOME)/extra/caltech-4/std-sift
P_TMP    := /tmp/

SIFT     := $(HOME)/src/siftpp/sift
SIFTFLAGS:= --threshold 0 --verbose

include dataset.mk
