import std.stdio : writefln;
import std.range : enumerate;

void main(string[] args) {
    foreach (argc, argv; args.enumerate)
        writefln("arg[%d] = <%s>", argc, argv);
}
