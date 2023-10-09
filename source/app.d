// https://www.youtube.com/live/8ESoL8d8GrE?si=Vsmb1cIHiuyl7i7g&t=1475

import std.stdio : writeln, writefln;

import std.range;
import std.algorithm;
import std.format;
import std.string : toStringz;

import dlangui;

mixin APP_ENTRY_POINT;

// extern (C) int main(int argc, const(char)** argv) {
// int main(string[] argv) {
extern (C) int UIAppMain(string[] args) {
    foreach (i, arg; args.enumerate)
        writefln("argv[%s] = <%s>", i, arg);
    auto wMain = Platform.instance.createWindow(to!dstring(args[0]), null,WindowFlag.Resizable,240,320);
    wMain.show();
    wMain.mainWidget = (new Button()).text("Hello");
    return Platform.instance.enterMessageLoop();
}
