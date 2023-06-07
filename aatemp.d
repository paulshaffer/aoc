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
writeln(compareChars("#", "."));
writeln(compareChars("#", "@"));
writeln(compareChars("#", "#"));
writeln(compareChars(".", "."));
writeln(compareChars(".", "@"));
writeln(compareChars(".", "#"));
writeln(compareChars("@", "."));
writeln(compareChars("@", "@"));
writeln(compareChars("@", "#"));




//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Result compareChars(string fromS, string toS) {
	Result result = Result.ignore;
	if(fromS == "@") {
		if(toS == "." || toS == "@") {
			result = Result.move;
		} else { // toS = "#" or "|"
			result = Result.end;
		}
	}	// else fromS = "." or "#", result.ignore
	return result;
}