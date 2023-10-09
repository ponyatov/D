// https://www.youtube.com/live/8ESoL8d8GrE?si=Vsmb1cIHiuyl7i7g&t=1475

import std.stdio : writeln, writefln;

import std.range;
import std.algorithm;
import std.format;

// extern (C) int main(int argc, const(char)** argv) {
int main(string[] argv) {
    foreach (i,arg; argv.enumerate)
        writefln("argv[%s] = <%s>", i, arg);
    return 0;
}
