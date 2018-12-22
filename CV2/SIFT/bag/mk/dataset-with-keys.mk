#  - Search P_IMAGES for categories and .jpg files
#  - Expect P_KEYS to be a corresponding hierarchy with the .key files
#  - Populates P_SIFTS with the corresponding .key and .desc files

# get categories
CATS   := $(shell ls $(P_IMAGES))

# get images within categories (.jpg files)
IMAGES := $(filter %.jpg,                                        \
	    $(foreach c, $(CATS),                                \
              $(addprefix $(c)/,                                 \
	        $(shell ls $(P_IMAGES)/$(c)) )))

# get output .key and .desc files
OKEYS  := $(IMAGES:.jpg=.key)
ODESCS := $(IMAGES:.jpg=.desc)

all: $(P_SIFTS) $(addprefix $(P_SIFTS)/, $(CATS)) $(addprefix $(P_SIFTS)/, $(OKEYS) $(ODESCS))

# --------------------------------------------------------------------
#                                                                Rules
# --------------------------------------------------------------------

# make output hierarchy
$(P_SIFTS) $(addprefix $(P_SIFTS)/,$(CATS)) :
	@echo Making directory $@
	@mkdir -p $@

# We define a rule for each image (implicit rules would not work here).
# This macro generates a rule, $(eval) later is used to add the rules
# to the makefile.

#$(call one-with-keys-rule, image-no-ext)
define one-with-keys-rule
$(P_SIFTS)/$1.key $(P_SIFTS)/$1.desc : \
	$(P_IMAGES)/$1.jpg $(P_KEYS)/$1.key
	convert $(P_IMAGES)/$1.jpg pgm:/$(P_TMP)/$(notdir $1).pgm
	$(SIFT) $(SIFTFLAGS) \
		--keypoints=$(P_KEYS)/$1.key  \
	        --prefix=$(P_SIFTS)/$(dir $1) \
		--binary $(P_TMP)/$(notdir $1).pgm
	rm /$(P_TMP)/$(notdir $1).pgm

endef

$(eval $(foreach i,$(IMAGES:.jpg=),$(call one-with-keys-rule,$(i))))

# --------------------------------------------------------------------
#                                                                Debug
# --------------------------------------------------------------------

.PHONY: info
info:
	@echo -e " CATS     =" $(CATS)
	@echo -e " IMAGES   =" $(wordlist 1,2,$(IMAGES)) "..."
	@echo -e " OKEYS    =" $(wordlist 1,2,$(OKEYS)) "..."
	@echo -e " ODESCS   =" $(wordlist 1,2,$(ODESCS)) "..."	


