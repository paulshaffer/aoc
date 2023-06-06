module aoc2217a2;

import std.algorithm;
import std.regex;
import std.stdio;
import std.file;
import core.time: MonoTime;
import std.conv;
import std.string: strip;

File f,fo,f2;

enum rockDropSpacing = 3;
enum numRocks = 2022;
enum tallestRock = 4;
enum chamberWidth = 9;
enum chamberHeight = tallestRock * numRocks;

struct Rock {
	char[][] yx; //row[] col[]
	int h, w; // height, width
}
Rock[] rocks;

char[chamberWidth][chamberHeight] chamber;
string jets;
int jetIndex;



// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2217a.data";
	f  = File("aoc2217a2.data");
	f2 = File(filename);
	fo = File("tempout.data","w");

	loadRocks();
	for(size_t rk; rk < rocks.length; rk++) {
		fo.writeln(rocks[rk].length);
		for(size_t rkl; rkl < rocks[rk].length; rkl++) {
			fo.writeln(rocks[rk][rkl]);
		}
	}

	buildChamber();

	jets = f2.readln.strip();

	int rk = -1;
	int rockFalls = 1;
	int stackHeight = 0, prevStackHeight = 0, rkLwrLeft = 0;
	while(rockFalls <= numRocks) {
		rk++; rk = rk < rocks.length ? rk : 0;
		rock = rocks[rk];
		rkLwrLeft = insertRock(stackHeight, rock);
		while(prevStackHeight != stackHeight) { // falling rock
			jetEffect();

			// if the stack height is unchanged after a rock fall event, the rock has settled
			prevStackHeight = stackHeight;
			fallEffect();
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
		fo.writeln(chamber[hgt]);
	}
}

int insertRock(ref int stackHeight, char[][] rock) {
	for(int i = 0; i < rock.length; i++) {
		chamber[stackHeight + rockDropSpacing + 1 + i][3..(3 + rock[0].length)] = to!string(rock[$-1-i]);
	}
	stackHeight += rock.length + rockDropSpacing;
	return 
}

void jetEffect() {
	int jet = jets[jetIndex] == '>' ? 1 : -1;
}
