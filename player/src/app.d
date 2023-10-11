import std.stdio : writefln, writeln;
import core.stdc.stdlib : abort;
import std.range : enumerate;
import std.string;
import std.range : iota;
import std.conv;

import bindbc.sdl;

// import bindbc.sdl_image;

auto mp3 = import("~/fx/media/dwsample1.mp3");

class AuDev {
    int id;
    string name;
    this(int id) {
        this.id = id;
        const char* _ = SDL_GetAudioDeviceName(id, false);
        assert(_ !is null);
        this.name = to!string(_);
        writeln(this);
    }

    override string toString() {
        return "<" ~ typeof(this).stringof ~ "|" ~ to!string(
                id) ~ ":" ~ name ~ ">";
    }
}

__gshared AuDev[] audev;

int main(string[] args) {
    foreach (argc, argv; args.enumerate)
        writefln("arg[%d] = <%s>", argc, argv);
    // dyn load: dub.json "bindbc-sdl": "dynamic"
    // assert(loadSDL() == sdlSupport);
    // assert(loadSDLImage() == sdlImageSupport);
    // init
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) != 0) {
        writeln("SDL_Init: ", SDL_GetError());
        abort();
    }
    scope (exit)
        SDL_Quit();
    // 
    const auto auDevs = SDL_GetNumAudioDevices(false);
    assert(auDevs);
    foreach (i; auDevs.iota)
        audev ~= new AuDev(i);
    //
    const winFlags = !SDL_WINDOW_RESIZABLE | SDL_WINDOW_SHOWN;
    const W = 240;
    const H = 320;
    auto wMain = SDL_CreateWindow(args[0].toStringz,
            SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, W, H, winFlags);
    if (!wMain) {
        writeln("SDL_CreateWindow: ", SDL_GetError());
        abort();
    }
    scope (exit)
        SDL_DestroyWindow(wMain);
    // 
    bool quit = false;
    SDL_Event event;
    while (!quit & false) {
        SDL_PumpEvents();
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_QUIT:
            case SDL_KEYDOWN:
                quit = true;
                break;
            default:
            }
        }
    }
    //
    return 0;
}
