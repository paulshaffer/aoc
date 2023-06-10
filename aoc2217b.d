module aoc2217b;

import std.algorithm;
import std.stdio;
import std.file;
import core.time: MonoTime;
import std.conv;
import std.string: strip;
import std.array: replace;

File f,fo,f2;

enum rockDropSpacing = 3;
enum numRocks = 2022;
enum tallestRock = 4;
enum chamberWidth = 9;
enum chamberHeight = tallestRock * numRocks;
enum Result {move, ignore, end}

char[chamberWidth][chamberHeight] chamber;
string jets;
ulong jetIndex;

struct Rock {
	char[][] yx; //row[] col[]
	ulong h, w; // height, width
}
Rock rock;
Rock[] rocks;

struct RockMarker {
	ulong top, bottom, left, right;
}
RockMarker rockMarker;


// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2217a.data";
	f  = File("aoc2217a2.data");
	f2 = File(filename);
	fo = File("tempout.data","w");

	loadRocks();
	rockShapeReplace("#","@");
	// printRocks();

	buildChamber();

	jets = f2.readln.strip();
	Result result;
	int rk = -1, rockFalls = 0, stackHeight = 0;
	while(rockFalls < numRocks ) { //numRocks
		rk++; rk = rk < rocks.length ? rk : 0;
		rock = rocks[rk];
		ulong prevMarkerTop = 0;
		rockMarker = insertRock(stackHeight, rock);
		while(prevMarkerTop != rockMarker.top) { // falling rock
			// if(prevMarkerTop == 0) {
			// 	batchJetEffect();
			// } else {
				jetEffect();
			// }
			// if the stack height is unchanged after a rock fall event, the rock has settled
			prevMarkerTop = rockMarker.top;
			result = fallEffect();
		}
		chamberShapeReplace(rockMarker,"@","#");
		stackHeight = rockMarker.top > stackHeight ? 
						to!int(rockMarker.top) : stackHeight;
		rockFalls++;
	}
printChamber(0, stackHeight + 5);
fo.writeln("stack height ", stackHeight);
fo.writeln(rockFalls);


//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void loadRocks() {
	string s;
	while(!f.eof()) {
		rocks ~= Rock();
		s = f.readln.strip;
		while(s != "") {
			rocks[$-1].yx ~= s.dup;
			s = f.readln.strip;
		}
		rocks[$-1].h = rocks[$-1].yx   .length;
		rocks[$-1].w = rocks[$-1].yx[0].length;
	}
}

void rockShapeReplace(string searchStr, string replaceStr) {
	foreach(ref rk;rocks)
		foreach(ref row;rk.yx)
			row = replace(row, searchStr, replaceStr);
}

void chamberShapeReplace(RockMarker rm, string searchStr, string replaceStr) {
	foreach(ref row;chamber[rm.bottom .. rm.top + 1]) {
			row = replace(row, searchStr, replaceStr);
	}
}

void printRocks() {
	foreach(rk; rocks) {
		fo.writeln(rk.h);
		foreach(rkl; rk.yx) {
			fo.writeln(rkl," ",rk.w);
		}
	}
}

void buildChamber() {
	for(size_t hgt = 1; hgt < chamber.length; hgt++) {
		chamber[hgt] = "|.......|";
	}
	chamber[0] = "+-------+";
}

void printChamber(int low, int high) {
	for(int hgt = high; hgt >= low; hgt--) {
		fo.writefln("%4s %s",hgt,chamber[hgt]);
	}
}

RockMarker insertRock(int stackHeight, Rock rock) {
	for(int i = 0; i < rock.h; i++) {
		chamber[stackHeight + 1 + i][3..(3 + rock.w)] = to!string(rock.yx[$-1-i]);
	}

	RockMarker marker = {
		top		: stackHeight + rockDropSpacing + rock.h,
		bottom	: stackHeight + rockDropSpacing + 1, 
		left	: 3,
		right	: 2 + rock.w };
	return marker;
}

void jetEffect() {
	int jet = jets[jetIndex] == '>' ? 1 : -1;
	jetIndex++; jetIndex = jetIndex < jets.length ? jetIndex : 0;
	char[9][] restore = chamber[rockMarker.bottom .. rockMarker.top + 1].dup;

	Result result;
	if(jet == -1) { // jet left
		for(ulong y = rockMarker.bottom; y <= rockMarker.top; y++) {
			for(ulong x = rockMarker.left; x <= rockMarker.right; x++) {
				char fromStr = chamber[y][x];
				char toStr   = chamber[y][x + jet];
				result = compareChars(fromStr, toStr);
				if(result == Result.move) {
					chamber[y][x + jet] = fromStr;
					chamber[y][x] = '.';
				} else if(result == Result.end) {
					break;
				} else if(result == Result.ignore) {
					continue;
				}
			}
			if(result == Result.end) {
				chamber[rockMarker.bottom .. rockMarker.top + 1] = restore.dup;
				break;
			}
		}
		if(result != Result.end) {
			rockMarker.left--; rockMarker.right--;
		}
	} else { // jet = 1, jet right
		for(ulong y = rockMarker.bottom; y <= rockMarker.top; y++) {
			for(ulong x = rockMarker.right; x >= rockMarker.left; x--) {
				char fromStr = chamber[y][x];
				char toStr   = chamber[y][x + jet];
				result = compareChars(fromStr, toStr);
				if(result == Result.move) {
					chamber[y][x + jet] = fromStr;
					chamber[y][x] = '.';
				} else if(result == Result.end) {
					break;
				} else if(result == Result.ignore) {
					continue;
				}
			}
			if(result == Result.end) {
				chamber[rockMarker.bottom .. rockMarker.top + 1] = restore.dup;
				break;
			}
		}
		if(result != Result.end) {
			rockMarker.left++; rockMarker.right++;
		}
	}
}





Result fallEffect() {
	char[9][] restore = chamber[rockMarker.bottom -1 .. rockMarker.top + 1].dup;

	Result result;
	for(ulong y = rockMarker.bottom; y <= rockMarker.top; y++) {
		for(ulong x = rockMarker.left; x <= rockMarker.right; x++) {
			char fromStr = chamber[y][x];
			char toStr   = chamber[y - 1][x];
			result = compareChars(fromStr, toStr);
			if(result == Result.move) {
				chamber[y][x] = '.';
				chamber[y - 1][x] = fromStr;
			} else if(result == Result.end) {
				break;
			} else if(result == Result.ignore) {
				continue;
			}
		}
		if(result == Result.end) {
			chamber[rockMarker.bottom - 1 .. rockMarker.top + 1] = restore.dup;
			break;
		}
	}
	if(result != Result.end) {
		rockMarker.top--; rockMarker.bottom--;
	}
	return result;
}

Result compareChars(char fromS, char toS) {
	Result result = Result.ignore;
	if(fromS == '@') {
		if(toS == '.' || toS == '@') {
			result = Result.move;
		} else { // toS = "#" or "|" or "-"
			result = Result.end;
		}
	}	// else fromS = "." or "#", result.ignore
	return result;
}
