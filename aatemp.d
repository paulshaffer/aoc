module aoc2216a;

import std.regex;
import std.stdio;
import std.file;
import core.time: MonoTime;
File fo;

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2216a.data";
	fo = File("tempout.data","w");

	auto s = readText(filename);
  //string s = "fhthgfh, AB, CD,dfgdg EF, GH, IJ\n, KL, MNdfgf, OP, QR, ST, UV\n";
	//auto ctr = ctRegex!(`Valve ([A-Z]{2}).*=(\d+).+?([A-Z]{2})(, [A-Z]{2})*`);
	auto ctr = ctRegex!(`Valve ([A-Z]{2}).*valves( ([A-Z]{2}))+`);
	foreach (c; matchAll(s, ctr)) {
		fo.writeln(c);
	}

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
