import std.stdio : writefln, writeln;
import std.range : enumerate;

import bindbc.sdl;
import bindbc.sdl_image;

int main(string[] args) {
    foreach (argc, argv; args.enumerate)
        writefln("arg[%d] = <%s>", argc, argv);
    // dyn load
    assert(loadSDL() == sdlSupport);
    // assert(loadSDLImage() == sdlImageSupport);
    //init
    if (SDL_Init(SDL_INIT_VIDEO) != 0)
        writeln("SDL_Init: ", SDL_GetError());
    SDL_Quit();
    return 0;
}
