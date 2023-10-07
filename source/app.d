// https://www.youtube.com/live/8ESoL8d8GrE?si=Vsmb1cIHiuyl7i7g&t=1475

import std.stdio : writeln;


// void main() {
extern (C) int main(int argc, const(char)** argv) {
    string msg = "Hello";
    writeln(msg);


    return 0;
}

static int x = 1234;

unittest {
    assert(x == 12351);
}
