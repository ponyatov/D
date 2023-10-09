module sdl2;

pragma(lib, "SDL2");

extern (C) int SDL_Init(uint flags);
int init(uint flags) {
    int _ = SDL_Init(flags);
    assert(_ == 0);
    return _;
}

extern (C) void SDL_Quit();
void quit() {
    SDL_Quit();
}

enum INIT : uint {
    TIMER = 0x00000001,
    AUDIO = 0x00000010,
    VIDEO = 0x00000020,
    JOYSTICK = 0x00000200,
    HAPTIC = 0x00001000,
    GAMECONTROLLER = 0x00002000,
    EVENTS = 0x00004000,
    EVERYTHING = 0x00008000,
    NOPARACHUTE = 0x00100000,
}

template BITSIZE(ushort x) {
    enum ushort BITSIZE = x & AudioFormat.MASK_BITSIZE;
}

enum AudioFormat : ushort {
    MASK_BITSIZE = (0xFF),
    MASK_DATATYPE = (1 << 8),
    MASK_ENDIAN = (1 << 12),
    MASK_SIGNED = (1 << 15),
    BITSIZE8 = BITSIZE!8,
    BITSIZE16 = BITSIZE!16,
    SIGNED = MASK_SIGNED,
    UNSIGNED = 0
}
