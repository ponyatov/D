// https://www.youtube.com/live/8ESoL8d8GrE?si=Vsmb1cIHiuyl7i7g&t=1475

import std.stdio : writeln;
import std.format;
import std.uni:toLower;
import std.string;

// void main() {
extern (C) int main(int argc, const(char)** argv) {
    string msg = "Hello";
    writeln(msg, '\t', (new MObject("Hello")).head("hello="));
    return 0;
}

unittest {
    assert(false);
}

class MObject {
    string value;

    string tag() {
        return typeof(this).stringof[1..$].toLower;
    }

    string val() {
        return value;
    }

    string head(string prefix = "") {
        return format("%s<%s:%s>", prefix, tag(), val());
    }

    this() {
    }

    this(string V) {
        this.value = V;
    }
}

class MPrimitive : MObject {
}

class MSym : MPrimitive {
}

class MStr : MPrimitive {
}

class MInt : MPrimitive {
}

class MContainer : MObject {
}

class MVector : MContainer {
}

class MStack : MContainer {
}

class MMap : MContainer {
}

class MActive : MObject {
}

class MVM : MActive {
}

class MCmd : MActive {
}

class MIO : MObject {
}

class MPath : MIO {
}

class MDir : MIO {
}

class MFile : MIO {
}
