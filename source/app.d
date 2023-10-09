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
    auto wMain = Platform.instance.createWindow(to!dstring(args[0]),
            null, WindowFlag.Resizable, 240, 320);
    Platform.instance.uiTheme = "theme_dark";
    wMain.backgroundColor = 0x222222;
    //
    auto layout = parseML(q{
        VerticalLayout {
            Button { id: hello; text: "Hello" }
            Button { id: world; text: "World" }
            TextWidget { id: log; text: "log"; backgroundColor: 0x777777 }
        }
    });
    // wMain.mainWidget = layout;
    //
    layout.childById("hello").click = delegate(Widget src) {
        layout.childById("log").text = src.text;
        return true;
    };
    layout.childById("world").click = delegate(Widget src) {
        layout.childById("log").text = src.text;
        return true;
    };
    // 
    auto grid = new StringGridWidget;
    grid.resize(3, 3);
    layout.addChild(grid);
    wMain.mainWidget = grid;
    //
    wMain.show();
    return Platform.instance.enterMessageLoop();
}
