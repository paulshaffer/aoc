module aoc2218b;

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
bool[dims][dims][dims] rocks;
Cube[dims][dims][dims] surface;
CubeForEval[] cubesforEval; 

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2218a.data";
	f = File(filename);
	fo = File("tempout.data","w");

	foreach (record; f.byLine.joiner("\n").csvReader!(Tuple!(byte, byte, byte))) {
		rocks[record[0]+2][record[1]+2][record[2]+2] = true;
	}

	cubesforEval ~= CubeForEval(1,1,1);
	while(cubesforEval.length != 0) {
		auto eval = cubesforEval[0];
		auto x=eval.x, y=eval.y, z=eval.z;
		auto xn=x-1, xf=x+1, yn=y-1, yf=y+1, zn=z-1, zf=z+1;
		if(xn >=  1) {
			if(rocks[xn][y][z] == true) {
				surface[x][y][z].yzn = 1;
			} else if(!surface[xn][y][z].listedForEvaluation) {
				surface[xn][y][z].listedForEvaluation = true;
				cubesforEval ~= CubeForEval(xn,y,z);
			}
		}
		if(xf <= 22) {
			if(rocks[xf][y][z] == true) {
				surface[x][y][z].yzf = 1;
			} else if(!surface[xf][y][z].listedForEvaluation) {
				surface[xf][y][z].listedForEvaluation = true;
				cubesforEval ~= CubeForEval(xf,y,z);
			}
		}
		if(yn >=  1) {
			if(rocks[x][yn][z] == true) {
				surface[x][y][z].xzn = 1;
			} else if(!surface[x][yn][z].listedForEvaluation) {
				surface[x][yn][z].listedForEvaluation = true;
				cubesforEval ~= CubeForEval(x,yn,z);
			}
		}
		if(yf <= 22) {
			if(rocks[x][yf][z] == true) {
				surface[x][y][z].xzf = 1;
			} else if(!surface[x][yf][z].listedForEvaluation) {
				surface[x][yf][z].listedForEvaluation = true;
				cubesforEval ~= CubeForEval(x,yf,z);
			}
		}
		if(zn >=  1) {
			if(rocks[x][y][zn] == true) {
				surface[x][y][z].xyn = 1;
			} else if(!surface[x][y][zn].listedForEvaluation) {
				surface[x][y][zn].listedForEvaluation = true;
				cubesforEval ~= CubeForEval(x,y,zn);
			}
		}
		if(zf <= 22) {
			if(rocks[x][y][zf] == true) {
				surface[x][y][z].xyf = 1;
			} else if(!surface[x][y][zf].listedForEvaluation) {
				surface[x][y][zf].listedForEvaluation = true;
				cubesforEval ~= CubeForEval(x,y,zf);
			}
		}
		cubesforEval = cubesforEval[1 .. $];
	}

	int count;
	for(int x=1;x<=22;x++) {
		for(int y=1;y<=22;y++) {
			for(int z=1;z<=22;z++) {
				if(surface[x][y][z].sts) {
					fo.writefln("%2s %2s %2s %1s",
								x,y,z,surface[x][y][z].sts._popcnt);
					count += surface[x][y][z].sts._popcnt;
				}
			}
		}
	}
	writeln(count);

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

struct Cube {
	bool listedForEvaluation;
	union {
		ubyte sts = 0;
		mixin(bitfields!(
			ubyte, "xyn", 1,
			ubyte, "xyf", 1,
			ubyte, "yzn", 1,
			ubyte, "yzf", 1,
			ubyte, "xzn", 1,
			ubyte, "xzf", 1,
			ubyte, "___", 2,));
	}
}

struct CubeForEval {
	int x,y,z;
}