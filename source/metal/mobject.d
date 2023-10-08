module metal.mobject;

import std.format;
import std.uni : toLower;
import std.string;

class MObject {
    string value;

    string tag() {
        return typeof(this).stringof[1 .. $].toLower;
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
