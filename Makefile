# var
MODULE = $(notdir $(CURDIR))

# rool
CURL = curl -L -o

# src
D += source/hello.d

# all
.PHONY: all
all: bin/$(MODULE)
	$^

bin/$(MODULE): $(D)
	dmd $^

# install
.PHONY: install update
install: /etc/apt/sources.list.d/d-apt.list
	sudo apt --allow-unauthenticated install -yu d-apt-keyring
	$(MAKE) update
update:
# sudo apt update
	sudo apt install -yu `cat apt.txt`
/etc/apt/sources.list.d/d-apt.list:
	sudo $(CURL) $@ http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list
