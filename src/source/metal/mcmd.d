module metal.mcmd;

import metal.mactive;

class MCmd : MActive {
    this(string V) {
        super(V);
    }

    void function() fn;
    this(void function() F) {
        fn = F;
        super(F.stringof);
    }
}

void nop() {
}
