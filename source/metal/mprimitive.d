module metal.mprimitive;

import metal.mobject;

class MPrimitive : MObject {
    this(string V) {
        super(V);
    }

    this() {
        super();
    }
}

class MSym : MPrimitive {
    this(string V) {
        super(V);
    }
}

class MStr : MPrimitive {
    this(string V) {
        super(V);
    }
}

class MInt : MPrimitive {
    int value = 0;

    this(int V) {
        value = V;
    }

    this(string V) {
        import std.conv;

        value = std.conv.to!int(V);
    }
}
