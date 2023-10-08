// https://www.youtube.com/live/8ESoL8d8GrE?si=Vsmb1cIHiuyl7i7g&t=1475

import std.stdio : writeln;

import metal;

// void main() {
extern (C) int main(int argc, const(char)** argv) {
    string msg = "Hello";
    writeln(msg, '\t', (new MSym("Hello")).head("\n\nhello = "));
    return 0;
}

unittest {
    assert(false);
}
