# * caltech-101 with random keys *

P_IMAGES := $(HOME)/data/caltech-101
P_KEYS   := $(HOME)/extra/caltech-101/rand-key
P_SIFTS  := $(HOME)/extra/caltech-101/rand-sift
P_TMP    := /tmp/

SIFT     := $(HOME)/src/siftpp/sift
SIFTFLAGS:= --threshold 0 --verbose

include dataset-with-keys.mk
