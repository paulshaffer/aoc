module aoc2216a;

import std.algorithm;
import std.regex;
import std.stdio;
import std.file;
import core.time: MonoTime;


// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------

ubyte[ubyte] aa = [1:7, 2:5, 13:35, 3:1];
aa.writeln;

foreach(key,value;aa) writeln(key," ",value);writeln;
foreach(key,value;aa.byValue) writeln(key," ",value);writeln;

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
