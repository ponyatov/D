module metal.mactive;

import metal.mobject;

class MActive : MObject {
    this(string V) {
        super(V);
    }

    this() {
        super();
    }
}

class MVM : MActive {
    this(string V) {
        super(V);
    }
}
