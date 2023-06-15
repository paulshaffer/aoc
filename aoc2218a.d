module aoc2218a;

import std.algorithm;
import std.stdio;
import std.file;
import core.time: MonoTime;
import std.conv;
import std.string: strip;
import std.array: replace;
import core.bitop: btc, bts, popcnt, _popcnt;
import std.bitmanip: bitfields;
import std.csv: csvReader;
import std.typecons: tuple, Tuple;
File f,fo;
enum dims = 32;
Cube[dims][dims][dims] cubes;
byte[byte][byte][byte] cubelist;

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2218a.data";
	f = File(filename);
	fo = File("tempout.data","w");

	foreach (record; f.byLine.joiner("\n").csvReader!(Tuple!(byte, byte, byte))) {
		cubes[record[0]][record[1]][record[2]].sts = 0b0011_1111;
		cubelist[record[0]][record[1]][record[2]]++;
	}
	cubelist.rehash;

	foreach(byte x, yzcubelist;cubelist) {
		foreach(byte y, zcubelist;yzcubelist) {
			foreach(byte z,val;zcubelist) {
				if(cubes[x][y][z].xyn) {
					byte zval = to!byte(z - 1);
					if(zval >= 0) {
						if(zval in cubelist[x][y]) {
							cubes[x][y][z].xyn = 0;
							cubes[x][y][zval].xyf = 0;
						}
					}
				}
				if(cubes[x][y][z].xyf) {
					byte zval = to!byte(z + 1);
					if(zval <= dims - 1) {
						if(zval in cubelist[x][y]) {
							cubes[x][y][z].xyf = 0;
							cubes[x][y][zval].xyn = 0;
						}
					}
				}
			}
		}
	}

	printCubes();

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

struct Cube {
	union {
		ubyte sts = 0;
		mixin(bitfields!(
			ubyte, "xyn", 1,
			ubyte, "xyf", 1,
			ubyte, "yzn", 1,
			ubyte, "yzf", 1,
			ubyte, "xzn", 1,
			ubyte, "xzf", 1,
			ubyte, "padding", 2));
	}
}

void printCubes() {
	size_t cnt;
	foreach(byte x, yzcubelist;cubelist) {
		foreach(byte y, zcubelist;yzcubelist) {
			foreach(byte z,val;zcubelist) {
				fo.writefln("%2s %2s %2s %1s",x,y,z,cubes[x][y][z].sts._popcnt);
				cnt += cubes[x][y][z].sts._popcnt;
			}
		}
	}
	fo.writeln(cnt);
}