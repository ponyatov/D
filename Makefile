# var
MODULE  = $(notdir $(CURDIR))
module  = $(shell echo $(MODULE) | tr A-Z a-z)
OS      = $(shell uname -o|tr / _)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# version
D_VER = 2.106.1
# LDC_VER = 1.34.0 debian 12 libc 2.29
# LDC_VER = 1.33.0 2.29 since 1.32.1
LDC_VER = 1.32.0

# dir
CWD  = $(CURDIR)
BIN  = $(CWD)/bin
SRC  = $(CWD)/src
TMP  = $(CWD)/tmp
REF  = $(CWD)/ref
GZ   = $(HOME)/gz

# tool
CURL = curl -L -o
CF   = clang-format
DC   = /usr/bin/dmd
DUB  = /usr/bin/dub
RUN  = $(DUB) run   --compiler=$(DC)
BLD  = $(DUB) build --compiler=$(DC)
LDC2 = $(CWD)/ldc/$(LDC_OS)/bin/ldc2

# src
D += $(wildcard src/*.d*)
D  = source/app.d \
		$(filter-out source/app.d, \
			$(wildcard source/*.d source/metal/*.d))
D += $(wildcard wasm/*.d)
D += $(wildcard player/src/*.d)
J += $(wildcard *.json)

# cfg
DFLAGS += -unittest
DFLAGS += -v
DFLAGS += -of=bin/$(MODULE) -od=tmp

# package
BUSYBOX    = busybox-$(BUSYBOX_VER)
BUSYBOX_GZ = $(BUSYBOX).tar.bz2

LDC    = ldc2-$(LDC_VER)
LDC_OS = $(LDC)-linux-x86_64
LDC_GZ = $(LDC_OS).tar.xz

# all
.PHONY: all
all: $(D)
	$(RUN)

# format
format: tmp/format_d
tmp/format_d: $(D)
	$(RUN) dfmt -- -i $? && touch $@

# rule
bin/$(MODULE): $(D) $(J) Makefile
	$(BLD)

$(REF)/%/configure: $(GZ)/%.tar.gz
	cd ref ; zcat $< | tar x && chmod +x $@ ; touch $@
$(REF)/%/README.md: $(GZ)/%.tar.gz
	cd ref ; zcat $< | tar x &&               touch $@

# doc
.PHONY: doc
doc:

doc/yazyk_D.pdf:
	$(CURL) $@ https://www.k0d.cc/storage/books/D/yazyk_programmirovaniya_d.pdf
doc/Programming_in_D.pdf:
	$(CURL) $@ http://ddili.org/ders/d.en/Programming_in_D.pdf
doc/d-readthedocs-io-en-latest.pdf:
	$(CURL) $@ https://github.com/ponyatov/D/releases/download/071023-5009/d-readthedocs-io-en-latest.pdf
doc/BuildWebAppsinVibe.pdf:
	$(CURL) $@ https://raw.githubusercontent.com/reyvaleza/vibed/main/BuildWebAppsinVibe.pdf

# install
.PHONY: install update gz
install: doc gz
	$(MAKE) update
	dub build dfmt
update:
	sudo apt update
	sudo apt install -yu `cat apt.txt`
gz: $(DC) $(DUB)

$(DC) $(DUB): $(HOME)/distr/SDK/dmd_$(D_VER)_amd64.deb
	sudo dpkg -i $< && sudo touch $(DC) $(DUB)
$(HOME)/distr/SDK/dmd_$(D_VER)_amd64.deb:
	$(CURL) $@ https://downloads.dlang.org/releases/2.x/$(D_VER)/dmd_$(D_VER)-0_amd64.deb

WASM_FLAGS += -mtriple=wasm32-unknown-unknown-wasm
WASM_FLAGS += --betterC
.PHONY: ldc
ldc: wasm/add.ll
wasm/%.wat: wasm/%.wasm
	wasm2wat $< -o $@
wasm/%.wasm: wasm/%.d $(LDC2)
	$(LDC2) $(WASM_FLAGS) -c $< --of=$@ && file $@
wasm/%.ll: wasm/%.d $(LDC2)
	$(LDC2) $(WASM_FLAGS) -c $< --output-ll --of=$@ && file $@
$(LDC2): $(GZ)/$(LDC_GZ)
	cd ldc ; xzcat $< | tar x && touch $@

$(GZ)/$(LDC_GZ):
	$(CURL) $@ https://github.com/ldc-developers/ldc/releases/download/v$(LDC_VER)/$(LDC_GZ)

.PHONY: os
os:
	make -C $@ gz all

.PHONY: src
src:

MP3 += ~/fx/media/dwsample1.mp3
MP4 += ~/media/video/park.mp4 ~/media/video/tubes.mp4
.PHONY: player
player:
	dub run :$@ -- $(MP3) $(MP4)

CLANG_11 = libclang-11.so.1
CLANG_DIR = /usr/lib/x86_64-linux-gnu
.PHONY: dpp
dpp: $(CLANG_DIR)/libclang.so
	dub build $@
$(CLANG_DIR)/libclang.so: $(CLANG_DIR)/$(CLANG_11)
	sudo ln -s $< $@
	sudo apt install -yu libclang-11-dev

# merge
MERGE += README.md Makefile apt.txt LICENSE
MERGE += .clang-format .doxygeb .editorconfig .gitignore
MERGE += .vscode bin doc inc src tmp ref

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

.PHONY: zip
zip:
	git archive \
		--format zip \
		--output $(TMP)/$(MODULE)_$(NOW)_$(REL).src.zip \
	HEAD
