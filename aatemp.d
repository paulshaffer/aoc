module aoc2216a;

import std.algorithm;
import std.regex;
import std.stdio;
import std.file;
import core.time: MonoTime;
import std.conv;


// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------

ulong fact(ulong n){
	return n>=2 ? (n) * fact(n-1) : 1;
}

writefln("%,3s",fact(to!ulong(args[1])));
writefln("%,3s",uint.max);



//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
