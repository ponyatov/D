import std.stdio : writefln, writeln;
import core.stdc.stdlib : abort;
import std.range : enumerate;
import std.string;
import std.range : iota;
import std.conv;

import bindbc.sdl;
import sdl.audio;

// import bindbc.sdl_image;

auto mp3 = import("media/dwsample1.mp3");

class AuDev {
    int id;
    string name;
    int freq = Audio.freq;
    SDL_AudioFormat format = Audio.format;
    ubyte channels = Audio.channels;
    this(int id) {
        this.id = id;
        const char* _ = SDL_GetAudioDeviceName(id, false);
        assert(_ !is null);
        this.name = to!string(_);
        writeln(this);
    }

    string tag() const {
        return typeof(this).stringof;
    }

    override string toString() const {
        return "<%s|%s:%s> freq:%s ch:%s format:%s%s".format(tag,
                id, name, freq, channels,
                SDL_AUDIO_ISSIGNED(format) ? 's' : 'u',
                SDL_AUDIO_BITSIZE(format));
    }
}

enum Audio {
    freq = 22_050,
    format = AUDIO_S8,
    channels = 1
}

class AuPlay : AuDev {
    this(int id) {
        super(id);
    }

    override string tag() const {
        return typeof(this).stringof;
    }

    static callback(AuDev dev, ubyte[] stream, uint len) {
        foreach (i; 0.iota(len)) {
            stream[i] = cast(ubyte)(i % 0xFF);
        }
    }

    void open(int freq = Audio.freq, SDL_AudioFormat format = Audio.format,
            ubyte channels = Audio.channels) {
    }

    void play(string filename = "~/fx/media/dwsample1.mp3") {
        SDL_AudioSpec desired, obtained;
        SDL_zero(&desired);
        SDL_zero(&obtained);
        desired.freq = Audio.freq;
        desired.format = Audio.format;
        desired.channels = Audio.channels;
        //
        AuPlay dev = auplay[0];
        dev.id = SDL_OpenAudioDevice(dev.name.toStringz, false,
                &desired, &obtained, SDL_AUDIO_ALLOW_ANY_CHANGE);
        if (dev.id <= 0) {
            writefln("%s\t%s", dev.toString, SDL_GetError);
            abort();
        }
        assert(desired.freq == obtained.freq);
        dev.freq = obtained.freq;
        assert(desired.format == obtained.format);
        dev.format = obtained.format;
        assert(desired.channels == obtained.channels);
        dev.channels = obtained.channels;
    }
}

class AuRec : AuDev {
    this(int id) {
        super(id);
    }

    override string tag() const {
        return typeof(this).stringof;
    }
}

__gshared AuPlay[] auplay;
__gshared AuRec[] aurec;

int main(string[] args) {
    foreach (argc, argv; args.enumerate)
        writefln("arg[%d] = <%s>", argc, argv);
    // dyn load: dub.json "bindbc-sdl": "dynamic"
    static if (!sdl.staticBinding) {
        assert(loadSDL() == sdlSupport);
        assert(loadSDLImage() == sdlImageSupport);
    }
    // init
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) != 0) {
        writeln("SDL_Init: ", SDL_GetError());
        abort();
    }
    scope (exit)
        SDL_Quit();
    // 
    const auto auOuts = SDL_GetNumAudioDevices(false);
    assert(auOuts);
    foreach (i; auOuts.iota)
        auplay ~= new AuPlay(i);
    const auto auIns = SDL_GetNumAudioDevices(true);
    assert(auIns);
    foreach (i; auIns.iota)
        aurec ~= new AuRec(i);
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
