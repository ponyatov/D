# var
MODULE  = $(notdir $(CURDIR))
module  = $(shell echo $(MODULE) | tr A-Z a-z)
OS      = $(shell uname -o|tr / _)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# version
QEMU_VER  = 8.1.1
# QEMU_VER  = 8.0.5
# QEMU_VER  = 7.2.6
# dir
CWD = $(CURDIR)
BIN = $(CWD)/bin
TMP = $(CWD)/tmp
SRC = $(CWD)/src
GZ  = $(HOME)/gz

# tool
CURL = curl -L -o

# src
D  = source/app.d \
		$(filter-out source/app.d, \
			$(wildcard source/*.d source/metal/*.d))
J += $(wildcard *.json)

# cfg
DC      = dmd
DFLAGS += -unittest
DFLAGS += -of=bin/$(MODULE) -od=tmp

# package
QEMU     = qemu-$(QEMU_VER)
QEMU_GZ  = $(QEMU).tar.xz

# all
.PHONY: all
all: $(D)
	rdmd $(DFLAGS) $<

bin/$(MODULE): $(D) $(J) Makefile
	dub build
# $(DC) $(DFLAGS) $^

doc: doc/yazyk_programmirovaniya_d.pdf

doc/yazyk_programmirovaniya_d.pdf:
	$(CURL) $@ https://www.k0d.cc/storage/books/D/yazyk_programmirovaniya_d.pdf

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
.PHONY: install update gz
install: doc gz /etc/apt/sources.list.d/d-apt.list
	sudo apt --allow-unauthenticated install -yu d-apt-keyring
	$(MAKE) update
	dub fetch dfmt
	sudo pip3 install meson
update:
# sudo apt update
	sudo apt install -yu `cat apt.txt`
/etc/apt/sources.list.d/d-apt.list:
	sudo $(CURL) $@ http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list

gz: $(GZ)/$(QEMU_GZ) $(GZ)/$(MESON_GZ)

# cross
.PHONY: src
src: $(SRC)/$(QEMU)/configure

$(GZ)/$(QEMU_GZ):
	$(CURL) $@ https://download.qemu.org/$(QEMU_GZ)

QEMU_TARGET += arm-softmmu
# QEMU_TARGET += i386-softmmu
# QEMU_TARGET += avr-softmmu
QEMU_CFG += --prefix=$(BIN)/$(QEMU) --disable-kvm
QEMU_CFG += --target-list="$(QEMU_TARGET)"

.PHONY: qemu
qemu: $(BIN)/$(QEMU)/bin/qemu-system-arm

$(BIN)/$(QEMU)/bin/qemu-system-arm: $(SRC)/$(QEMU)/configure
	mkdir $(TMP)/qemu ; cd $(TMP)/qemu ;\
	$< $(QEMU_CFG)

# merge

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags

