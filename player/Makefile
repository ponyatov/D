# var
MP3 = ~/fx/media/dwsample1.mp3

# cfg
DFLAGS += -J=$(HOME)/fx

# all
.PHONY: all
all: src
	dub $(DFLAGS) run -- $(MP3)

# install
.PHONY: src
src: ref/Zardoz89/dub.json

ref/Zardoz89/dub.json:
	git clone --depth 1 https://github.com/Zardoz89/dlang-bindbc-sdl-opengl-example.git ref/Zardoz89
