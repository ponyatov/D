# var
MODULE  = $(notdir $(CURDIR))
module  = $(shell echo $(MODULE) | tr A-Z a-z)
OS      = $(shell uname -o|tr / _)
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# rool
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

# install
.PHONY: install update
install: doc /etc/apt/sources.list.d/d-apt.list
	sudo apt --allow-unauthenticated install -yu d-apt-keyring
	$(MAKE) update
	dub fetch dfmt
update:
# sudo apt update
	sudo apt install -yu `cat apt.txt`
/etc/apt/sources.list.d/d-apt.list:
	sudo $(CURL) $@ http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list

# merge

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
