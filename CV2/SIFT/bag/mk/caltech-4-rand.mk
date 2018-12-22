# * caltech-4 with random keys *

P_IMAGES := $(HOME)/data/caltech-4
P_KEYS   := $(HOME)/extra/caltech-4/rand-key
P_SIFTS  := $(HOME)/extra/caltech-4/rand-sift
P_TMP    := /tmp/

SIFT     := $(HOME)/src/siftpp/sift
SIFTFLAGS:= --threshold 0 --verbose

include dataset-with-keys.mk
