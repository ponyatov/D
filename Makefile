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
LDC_VER = 1.33.0

# dir
CWD = $(CURDIR)
BIN = $(CWD)/bin
TMP = $(CWD)/tmp
SRC = $(CWD)/src
GZ  = $(HOME)/gz

# tool
CURL = curl -L -o
LDC2 = $(CWD)/ldc/$(LDC_OS)/bin/ldc2

# src
D  = source/app.d \
		$(filter-out source/app.d, \
			$(wildcard source/*.d source/metal/*.d))
J += $(wildcard *.json)

# cfg
DC      = dmd
DFLAGS += -unittest
# DFLAGS += -v
DFLAGS += -of=bin/$(MODULE) -od=tmp

# package
LDC    = ldc2-$(LDC_VER)
LDC_OS = $(LDC)-linux-x86_64
LDC_GZ = $(LDC_OS).tar.xz

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

.PHONY: ldc
ldc: $(LDC2)
	$(LDC2)
$(LDC2): $(GZ)/$(LDC_GZ)
	cd ldc ; xzcat $< | tar x && touch $@

$(GZ)/$(LDC_GZ):
	$(CURL) $@ https://github.com/ldc-developers/ldc/releases/download/v$(LDC_VER)/$(LDC_GZ)

.PHONY: src
src:refs/Zardoz89/dub.json

refs/Zardoz89/dub.json:
	git clone https://github.com/Zardoz89/dlang-bindbc-sdl-opengl-example.git src/Zardoz89

# merge

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
