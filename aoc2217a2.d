module aoc2217a2;

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

	int rk = -1, rockFalls = 1, stackHeight = 0, prevStackHeight = 0;
	while(rockFalls <= 5 ) { //numRocks
		rk++; rk = rk < rocks.length ? rk : 0;
		rock = rocks[rk];
		rockMarker = insertRock(stackHeight, rock); fo.write(rockMarker," ");
		while(prevStackHeight != stackHeight) { // falling rock
			jetEffect();

			// if the stack height is unchanged after a rock fall event, the rock has settled
			prevStackHeight = stackHeight;
			// fallEffect();
		}
		rockFalls++;
	}
printChamber(0, stackHeight + 5);


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

RockMarker insertRock(ref int stackHeight, Rock rock) {
	for(int i = 0; i < rock.h; i++) {
		chamber[stackHeight + rockDropSpacing + 1 + i][3..(3 + rock.w)] = to!string(rock.yx[$-1-i]);
	}

	RockMarker marker = {
		top		: stackHeight + rockDropSpacing + rock.h,
		bottom	: stackHeight + rockDropSpacing + 1, 
		left	: 3,
		right	: 2 + rock.w };

	stackHeight += rockDropSpacing + rock.h;
	return marker;
}

void jetEffect() {
	int jet = jets[jetIndex] == '>' ? 1 : -1;
	fo.writefln("jet %2s jetIndex %5s",jet,jetIndex);
	jetIndex++; jetIndex = jetIndex < jets.length ? jetIndex : 0;
	char[9][] restore = chamber[rockMarker.bottom .. rockMarker.top + 1];

	Result result;
	for(ulong y = rockMarker.bottom; y <= rockMarker.top; y++) {
		for(ulong x = rockMarker.left; x <= rockMarker.right; x++) {
		}
	if(result = Result.end) break;
	}

	if(result = Result.end) {
		chamber[rockMarker.bottom .. rockMarker.top + 1] = restore;
	}
}

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
