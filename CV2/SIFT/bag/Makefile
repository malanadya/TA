# file:        Makefile
# author:      Andrea Vedaldi
# description: Build mex files

# --------------------------------------------------------------------
#
# --------------------------------------------------------------------

# Determine on the flight the system we are running on
Darwin_ARCH := mac
Linux_ARCH  := glx
ARCH := $($(shell uname)_ARCH)

mac_CFLAGS       := -O -I. -pedantic -Wall
mac_MEX_CFLAGS   := -g CFLAGS='$$CFLAGS $(mac_CFLAGS)'
mac_MEX_SUFFIX   := mexmac

glx_CFLAGS       := -O -I. -pedantic -Wall
glx_MEX_CFLAGS   := -g CFLAGS='$$CFLAGS $(glx_CFLAGS)'
glx_MEX_SUFFIX   := mexglx

MEX_SUFFIX       := $($(ARCH)_MEX_SUFFIX)
MEX_CFLAGS       := $($(ARCH)_MEX_CFLAGS)

VER              := 0.1.6
DIST             := bag-$(VER)

# --------------------------------------------------------------------
#
# --------------------------------------------------------------------

vpath %.mex.c .

src  := $(wildcard *.mex.c)
msrc := $(wildcard *.m)
stem := $(notdir $(basename $(basename $(src))))
tgt  := $(addprefix mex/, $(addsuffix .$(MEX_SUFFIX),$(stem)))

mex/%.$(MEX_SUFFIX) : %.mex.c
	mex -I. $(MEX_CFLAGS) $< -outdir 'mex'
	@mv mex/$*.mex.$(MEX_SUFFIX) mex/$*.$(MEX_SUFFIX)

.PHONY: all
all: $(tgt)

.PHONY: info
info :
	@echo src = $(src)
	@echo stem = $(stem)
	@echo tgt = $(tgt)

# PDF documentation
.PHONY: doc
doc: vlutil.html

vlutil.html : $(msrc)
	mdoc --output=vlutil.html vl

.PHONY: clean
clean:
	rm -f $(tgt)
	rm -f .DS_Store .gdb_history
	find . -name '*~' -exec rm -f \{\} \;

.PHONY: distclean
distclean: clean
	rm -f mex/*.mexmac mex/*.mexglx
	rm -f vlutil.html
	rm -f bag-*.tar.gz

.PHONY: dist
dist: distclean
	echo Version $(VER) >TIMESTAMP
	echo Archive created on `date` >>TIMESTAMP
	d=$(notdir $(CURDIR)) ; \
	tar chzvf $(DIST).tar.gz ../$${d} 

.PHONY: autorights
autorights:
	autorights . \
	  --verbose \
	  --recursive \
	  --template cal \
	  --years 2006 \
	  --authors "Andrea Vedaldi (UCLA VisionLab)" \
	  --program "Bags"
