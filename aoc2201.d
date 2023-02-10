module aoc2201;

import std.stdio;
import std.string: strip;
import std.conv: to;
import std.algorithm: sort;

void main() {
	size_t currcals;
	size_t[] cals;
	File datafile = File("aoc2201.data","r");

	while (!datafile.eof()) {
		string line = datafile.readln.strip;
		if (line == "") {
			cals ~= currcals;
			currcals=0;
		}
		else currcals += to!int(line);
	}
	cals ~= currcals;

	cals.sort!("a>b");

	size_t total;
    for (int cnt=0; cnt<3; ++cnt) {
		total += cals[cnt];
        write(' ', cals[cnt]);
    }
	writeln('\n',total);
}