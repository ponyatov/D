# var
TARGET = i486-elf

# version
LDC_VER  = 1.32.0
LLVM_VER = 15

# dir
CWD = $(CURDIR)
SRC = $(CWD)/src
TMP = $(CWD)/tmp

# package
LDC    = ldc2-$(LDC_VER)
LDC_OS = $(LDC)-linux-x86_64

# tool
CURL = curl -L -o
LDC2 = $(CWD)/../ldc/$(LDC_OS)/bin/ldc2
AS   = llvm-as-$(LLVM_VER)
LLC  = llc-$(LLVM_VER)

# cfg
DFLAGS += -mtriple=$(TARGET) --od=$(TMP)
DFLAGS += --betterC

# all
.PHONY: all
all: $(TMP)/os.S

# rule
$(TMP)/%.ll: $(SRC)/%.d Makefile
	$(LDC2) $(DFLAGS) --of=$@ -c $< --output-ll
$(TMP)/os.S: $(TMP)/os.ll Makefile
	$(LLC) -o $@ $<

gz: ref/minimal.zip

ref/minimal.zip:
	$(CURL) $@ http://arsdnet.net/dcode/minimal.zip
