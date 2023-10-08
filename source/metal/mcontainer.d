module metal.mcontainer;

import metal.mobject;

class MContainer : MObject {
    this(string V) {
        super(V);
    }
}

class MVector : MContainer {
    this(string V) {
        super(V);
    }
}

class MStack : MContainer {
    this(string V) {
        super(V);
    }
}

class MMap : MContainer {
    this(string V) {
        super(V);
    }
}
