module aoc2216a;

import std.algorithm;
import std.regex;
import std.stdio;
import std.file;
import core.time: MonoTime;
import std.conv;

enum Result{move, ignore, end}

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
string s = "######";
ulong l = to!ulong(s);
writeln(s);
writeln(l);





//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

