# var
MODULE = $(notdir $(CURDIR))

# rool
CURL = curl -L -o

# src
D += $(wildcard source/*.d)

# cfg
DCC = dmd
DCFLAGS += -od=tmp

# all
.PHONY: all
all: bin/$(MODULE)
	$^

bin/$(MODULE): $(D)
	time $(DCC) $(DCFLAGS) -of=$@ $(D) && file $@

doc: doc/yazyk_programmirovaniya_d.pdf

doc/yazyk_programmirovaniya_d.pdf:
	$(CURL) $@ https://www.k0d.cc/storage/books/D/yazyk_programmirovaniya_d.pdf

# format
DFMT += --brace_style allman --end_of_line lf -t space
format: tmp/format_d
tmp/format_d: $(D)
	dub run dfmt -- $(DFMT) -i $(D) && touch $@
$(D): .editorconfig
	touch $@ ; $(MAKE) tmp/format_d

# install
.PHONY: install update
install: doc /etc/apt/sources.list.d/d-apt.list
	sudo apt --allow-unauthenticated install -yu d-apt-keyring
	$(MAKE) update
update:
	dub fetch dfmt
# sudo apt update
# sudo apt install -yu `cat apt.txt`
/etc/apt/sources.list.d/d-apt.list:
	sudo $(CURL) $@ http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list
