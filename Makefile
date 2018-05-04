MIX_TARGET := $(MIX_TARGET)
MIX_ENV := $(MIX_ENV)

ifeq ($(MIX_ENV),)
$(warning MIX_ENV not set. Invoke via mix)
MIX_ENV := dev
endif

ifeq ($(MIX_TARGET),)
$(warning MIX_TARGET not set. Invoke via mix)
MIX_TARGET := host
endif
MRUBY_SRC_DIR := c_src/mruby
MRUBY_BUILD_DIR := $(MRUBY_SRC_DIR)/build

# Mruby compiler
HOST_MRBC := $(MRUBY_BUILD_DIR)/host/bin/mrbc

# Source and output ruby files.
RB_SRC_DIR := ruby_lib
RB_SRC_FILES := $(shell find $(RB_SRC_DIR)/ -type f -name '*.rb')

ifeq ($(MIX_ENV), test)
RB_TEST_DIR := ruby_test
RB_TEST_FILES := $(shell find $(RB_TEST_DIR)/ -type f -name '*.rb')
$(info Loading tests $(RB_TEST_FILES))
endif

RB_BIN_DIR := priv/mrb
RB_BIN_FILES := $(patsubst $(RB_SRC_DIR)/%.rb, $(RB_BIN_DIR)/%.mrb, $(RB_SRC_FILES) $(RB_TEST_FILES))

TARGET_MRUBY := priv/mruby

# Host Mruby files
HOST_MRUBY_EXES := $(MRUBY_BUILD_DIR)/host/bin/mirb \
$(MRUBY_BUILD_DIR)/host/bin/mrbc \
$(MRUBY_BUILD_DIR)/host/bin/mruby \
$(MRUBY_BUILD_DIR)/host/bin/mruby-strip

# Host Mruby compile options.
HOST_MRUBY_BUILD_CONFIG := MRUBY_CONFIG=$(PWD)/mruby_build_config.rb \
CC=$(CC) \
AR=$(AR) \
YACC=$(YACC) \
MIX_TARGET=$(MIX_TARGET) \
MIX_ENV=$(MIX_ENV)

# Files that aren't real files.
.PHONY: all clean all-clean host-mruby-clean mruby-src-clean

all: $(RB_BIN_DIR) $(HOST_MRUBY_EXES) $(TARGET_MRUBY) $(RB_BIN_FILES)

# Mruby Host exes.
$(MRUBY_BUILD_DIR)/host/bin/mirb: .host-mruby
$(MRUBY_BUILD_DIR)/host/bin/mrbc: .host-mruby
$(MRUBY_BUILD_DIR)/host/bin/mruby: .host-mruby
$(MRUBY_BUILD_DIR)/host/bin/mruby-strip: .host-mruby

$(RB_BIN_DIR):
	mkdir -p $(RB_BIN_DIR)

.host-mruby:
	$(MAKE) -s -C $(MRUBY_SRC_DIR) -e $(HOST_MRUBY_BUILD_CONFIG)
	@echo 1 >> .host-mruby

host-mruby-clean:
	$(MAKE) -C $(MRUBY_SRC_DIR) clean -e $(HOST_MRUBY_BUILD_CONFIG)
	$(RM) $(TARGET_MRUBY)
	$(RM) .host-mruby

$(RB_BIN_DIR)/%.mrb: $(RB_SRC_DIR)/%.rb
	$(HOST_MRBC) -o $@ $<

$(TARGET_MRUBY):
	cp $(MRUBY_BUILD_DIR)/$(MIX_TARGET)-$(MIX_ENV)/bin/mruby $@

mruby-src-clean:
	$(RM) $(RB_BIN_FILES)

clean: mruby-src-clean

all-clean: clean host-mruby-clean
