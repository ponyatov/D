module metal.mactive;

import metal.mobject;

class MActive : MObject {
    this(string V) {
        super(V);
    }
}

class MVM : MActive {
    this(string V) {
        super(V);
    }
}

class MCmd : MActive {
    this(string V) {
        super(V);
    }
}
