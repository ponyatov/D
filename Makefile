# var
MODULE  = $(notdir $(CURDIR))
module  = $(shell echo $(MODULE) | tr A-Z a-z)
OS      = $(shell uname -o|tr / _)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# version
# LDC_VER = 1.34.0 debian 12 libc 2.29
# LDC_VER = 1.33.0 2.29 since 1.32.1
LDC_VER = 1.32.0

# dir
CWD = $(CURDIR)
BIN = $(CWD)/bin
SRC = $(CWD)/src
TMP = $(CWD)/tmp
GZ  = $(HOME)/gz

# package
LDC    = ldc2-$(LDC_VER)
LDC_OS = $(LDC)-linux-x86_64
LDC_GZ = $(LDC_OS).tar.xz

# tool
CURL = curl -L -o
LDC2 = $(CWD)/ldc/$(LDC_OS)/bin/ldc2

# src
D  = source/app.d \
		$(filter-out source/app.d, \
			$(wildcard source/*.d source/metal/*.d))
D += $(wildcard wasm/*.d)
D += $(wildcard player/src/*.d)
J += $(wildcard *.json)

# cfg
DC      = dmd
DFLAGS += -unittest
DFLAGS += -v
DFLAGS += -of=bin/$(MODULE) -od=tmp

# all
.PHONY: all
all: $(D)
	dub run
# rdmd $(DFLAGS) $<

bin/$(MODULE): $(D) $(J) Makefile
	dub build
# $(DC) $(DFLAGS) $^

doc: doc/yazyk_programmirovaniya_d.pdf doc/Programming_in_D.pdf \
	 doc/d-readthedocs-io-en-latest.pdf doc/BuildWebAppsinVibe.pdf

doc/yazyk_programmirovaniya_d.pdf:
	$(CURL) $@ https://www.k0d.cc/storage/books/D/yazyk_programmirovaniya_d.pdf
doc/Programming_in_D.pdf:
	$(CURL) $@ http://ddili.org/ders/d.en/Programming_in_D.pdf
doc/d-readthedocs-io-en-latest.pdf:
	$(CURL) $@ https://github.com/ponyatov/D/releases/download/071023-5009/d-readthedocs-io-en-latest.pdf
doc/BuildWebAppsinVibe.pdf:
	$(CURL) $@ https://raw.githubusercontent.com/reyvaleza/vibed/main/BuildWebAppsinVibe.pdf

# format
format: tmp/format_d
tmp/format_d: $(D)
	dub run dfmt -- -i $? && touch $@
$(D) $(J): .editorconfig
	touch $@ ; $(MAKE) tmp/format_d

# rule
$(SRC)/%/configure: $(GZ)/%.tar.gz
	cd src ; zcat $< | tar x && chmod +x $@ ; touch $@
$(SRC)/%/README.md: $(GZ)/%.tar.gz
	cd src ; zcat $< | tar x &&               touch $@

# install
APT_SRC = /etc/apt/sources.list.d
ETC_APT = $(APT_SRC)/d-apt.list $(APT_SRC)/llvm.list
.PHONY: install update gz
install: doc gz $(ETC_APT)
	sudo apt update && sudo apt --allow-unauthenticated install -yu d-apt-keyring
	$(MAKE) update
	dub fetch dfmt
update:
	sudo apt update
	sudo apt install -yu `cat apt.txt`
$(APT_SRC)/%: tmp/%
	sudo cp $< $@
tmp/d-apt.list:
	sudo $(CURL) $@ http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list

gz: $(GZ)/$(LDC_GZ)

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

# ref

.PHONY: ref
ref: ref/bindbc-sdl ref/bindbc-loader

ref/bindbc-sdl:
	git clone --depth 1 https://github.com/BindBC/bindbc-sdl.git $@
ref/bindbc-loader:
	git clone --depth 1 https://github.com/BindBC/bindbc-loader.git $@

# merge

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
