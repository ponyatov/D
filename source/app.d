// https://www.youtube.com/live/8ESoL8d8GrE?si=Vsmb1cIHiuyl7i7g&t=1475

import std.stdio : writeln;

import metal;

import std.range;
import std.algorithm;
import std.format;

// void main() {
extern (C) int main(int argc, const(char)** argv) {
    string msg = "Hello";
    writeln(msg, '\t', (new MCmd(&nop)).head("\n\nhello = "));
    // C();
    writeln("sdl2.init = ", sdl2.init(sdl2.INIT.AUDIO | sdl2.INIT.VIDEO));
    writeln("bitsize: ", AudioFormat.BITSIZE8 | AudioFormat.SIGNED);
    writeln("iota:\t", 10.iota
            .map!"a+1"
            .map!(a => "media%.2d".format(a))
            .chunks(3));
    sdl2.quit;
    return 0;
}

import c;

extern (C) void D() {
    // writeln("D");
}

unittest {
    assert(false);
}
