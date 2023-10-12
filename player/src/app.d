import std.stdio : writefln, writeln;
import core.stdc.stdlib : abort;
import std.range : enumerate;
import std.string;
import std.range : iota;
import std.conv;

import bindbc.sdl;
import sdl.audio;
import sdl_mixer;

// import bindbc.sdl_image;

auto mp3 = import("media/dwsample1.mp3");

enum int FREQ_11025 = 11_025, FREQ_22050 = 22_050,
        FREQ_41800 = 41_800, FREQ_48000 = 48_000;

class AudioFormat {
    SDL_AudioFormat sdl_format = Audio.sdl_format;
    int freq = Audio.freq;
    ubyte channels = Audio.channels;

    this(int freq = Audio.freq, SDL_AudioFormat sdl_format = Audio.sdl_format,
            ubyte channels = Audio.channels) {
        this.freq = freq;
        this.sdl_format = sdl_format;
        this.channels = channels;
    }

    override string toString() const {
        return "%s%s%sx%s".format(freq, SDL_AUDIO_ISSIGNED(sdl_format)
                ? 's' : 'u', SDL_AUDIO_BITSIZE(sdl_format), channels);
    }
}

class AuDev {
    int id;
    string name;
    AudioFormat format;
    this(int id, bool iscapture) {
        this.id = id;
        const char* namez = SDL_GetAudioDeviceName(id, iscapture);
        assert(namez !is null);
        this.name = to!string(namez);
        writeln(this);
    }

    string tag() const {
        return typeof(this).stringof;
    }

    override string toString() const {
        return "<%s|%s:%s> %s".format(tag, id, name, format);
    }
}

enum Audio {
    freq = FREQ_22050,
    sdl_format = AUDIO_S8,
    channels = 1
}

enum Video {
    W = 320,
    H = 240
}

class PlayList {
    MediaFile[] pl;
    MediaFile current = null;

    void add(string filename) {
        if (filename.endsWith(".mp3")) {
            pl ~= new MP3(filename);
        } else if (filename.endsWith(".mp4")) {
            pl ~= new MP4(filename);
        } else {
            writeln("unknown format\t", filename);
            abort();
        }
    }

    void play() {
        if (pl.length == 0)
            return;
        if (current is null)
            current = pl[0];
        current.play();
    }
}

class MediaFile {
    string filename;

    this(string filename) {
        this.filename = filename;
    }

    void play() {
        abort();
    }
}

class MP4 : MediaFile {
    this(string filename) {
        super(filename);
        writeln(__FILE__,':',__LINE__,"\tMediaFile");
        abort();
    }
}

class MP3 : MediaFile {
    Mix_Music* music;
    this(string filename) {
        super(filename);
        music = Mix_LoadMUS(filename.toStringz);
        assert(music !is null);
    }

    ~this() {
        if (music !is null)
            Mix_FreeMusic(music);
    }

    override void play() {
        Mix_PlayMusic(music, 1);
    }
}

class AuPlay : AuDev {
    this(int id) {
        super(id, false);
    }

    ~this() {
        close();
    }

    void close() {
        if (format !is null) {
            SDL_CloseAudioDevice(id);
            format = null;
            writeln("\n\n", this, "\tclosed\t", id);
        }
    }

    override string tag() const {
        return typeof(this).stringof;
    }

    static callback(AuDev dev, ubyte[] stream, uint len) {
        foreach (i; 0.iota(len)) {
            stream[i] = cast(ubyte)(i % 0xFF);
        }
    }

    void open(bool master = true) {
        // 
        SDL_AudioSpec desired, obtained;
        SDL_zero(&desired);
        SDL_zero(&obtained);
        desired.freq = Audio.freq;
        desired.format = Audio.sdl_format;
        desired.channels = Audio.channels;
        //
        id = SDL_OpenAudioDevice(master ? null : name.toStringz,
                false, &desired, &obtained, 0); // SDL_AUDIO_ALLOW_ANY_CHANGE);
        if (id <= 0) {
            writefln("\n\n%s\t%s", this, SDL_GetError.fromStringz);
            abort();
        }
        format = new AudioFormat(obtained.freq,
                obtained.format, obtained.channels);
        writeln(this);
    }

    void play(string filename = "~/fx/media/dwsample1.mp3") {
    }
}

class AuRec : AuDev {
    this(int id) {
        super(id, true);
    }

    override string tag() const {
        return typeof(this).stringof;
    }
}

__gshared AuPlay[] auplay;
__gshared AuRec[] aurec;
__gshared auto playlist = new PlayList();

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
    auplay[0].open();
    scope (exit)
        auplay[0].close();
    //
    const winFlags = !SDL_WINDOW_RESIZABLE | SDL_WINDOW_SHOWN;
    const W = Video.W;
    const H = Video.H;
    auto wMain = SDL_CreateWindow(args[0].toStringz,
            SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, W, H, winFlags);
    if (!wMain) {
        writeln("SDL_CreateWindow: ", SDL_GetError());
        abort();
    }
    scope (exit)
        SDL_DestroyWindow(wMain);
    //
    const auto mixer_flags = MIX_INIT_MP3;
    assert(mixer_flags == Mix_Init(mixer_flags));
    auto f = auplay[0].format;
    assert(Mix_OpenAudio(f.freq, f.sdl_format, f.channels, 0) == 0);
    // Mix_OpenAudioDevice(f.freq,f.sdl_format,f.channels,0,auplay[0].name.toStringz,false);
    assert(args.length >= 1);
    foreach (file; args[1 .. $])
        playlist.add(file);
    playlist.play();
    // 
    bool quit = false;
    SDL_Event event;
    while (!quit) {
        SDL_Delay(250);
        SDL_PumpEvents();
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_QUIT:
            case SDL_KEYDOWN:
            case SDL_MOUSEBUTTONDOWN:
                quit = true;
                break;
            default:
            }
        }
    }
    //
    return 0;
}
