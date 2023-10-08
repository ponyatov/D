module metal.mprimitive;

import metal.mobject;

class MPrimitive : MObject {
    this(string V);
}

class MSym : MPrimitive {
    this(string V);
}

class MStr : MPrimitive {
    this(string V);
}

class MInt : MPrimitive {
    this(string V);
}
