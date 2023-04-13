module aoc2214a;
/*
This coding challenge is from the AdventofCode.com/2022, day 14, part a.
	It is a challenge of sand falling and accumulating through various
	horizontal and vertical barriers.  The data is in the form of 150
	lines of text.  Each line has chains of cartesian points that
	represent various physical barriers to the sand.  An example of
	a line of points is: 511,13 -> 511,23 -> 515,23.  The sand is dropped
	from point 500,0.  The goal is determine how many units of sand will
	be dropped, and settle securely, until there is no place for units of
	sand to settle and they all fall through.  For a more detailed
	description see the above mentioned website.
*/

import std.stdio;
import std.file: readText;
import std.string;
import std.format;
import std.array;
import std.algorithm;
import std.conv: to;
import core.time: MonoTime;

File f;
File fo;
string[] header, grid;

struct MaxNmins {
	size_t xmin,xmax, ymin,ymax;
}
MaxNmins maxAndmins;


// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------

	// enum filename ="temp.data";
	enum filename ="aoc2214a.data";
	f = File(filename);
	fo = File("tempout2.data","w");

	// Scan data for x and y maxs and mins; with this info we don't have to
	// build the whole grid from zero to 500+ columns; if the range of x
	// values is ex. 475 to 525, then only that portion of the grid needs to be
	// worked with.
	maxAndmins = scanData(filename);

	// build a 3 line header/footer to print with the 'grid'
	// -for reference/troubleshooting
	//...4455..etc
	//...9900..etc
	//...8901..etc
	header = buildGridHeader();

	// Start with building an empty text grid; then insert the
	// barrier, #, information into the grid.
	// ......
	// ......
	// ...... ..etc
	grid = buildEmptyTextgrid();
	//Place a '+' marker in the grid for reference.  This is
	// where the sand starts (500,0).
	placeGridChar("+",500,0);
	
	// read barrier data into grid
	readDataIntoGrid();
	// we now have ex.	...................
	//					......#............
	//					......#..#.........
	//					......####.........
	//					...................


	// Start the sand-drop simulation from x=500, y=0.
	// Each cartesian point is one unit of sand.
	// ----------------------------------
	// ..from the AdventOfCode website...
	// "A unit of sand always falls down one step if possible. 
	// If the tile immediately below is blocked (by rock or sand), 
	// the unit of sand attempts to instead move diagonally one 
	// step down and to the left. If that tile is blocked, the 
	// unit of sand attempts to instead move diagonally one step 
	// down and to the right. Sand keeps moving as long as it is 
	// able to do so, at each step trying to move down, then 
	// down-left, then down-right. If all three possible 
	// destinations are blocked, the unit of sand comes to rest 
	// and no longer moves, at which point the next unit of sand 
	// is created back at the source".
	dumpTheSand();

	maxAndmins.writeln;
	printGridSolutionToTextFile();

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



// =============================================================================
// ------------------------------ FUNCTIONS ------------------------------------
// VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

void printGridSolutionToTextFile() {
	foreach(line;header) fo.writeln(line); // header for reference
	foreach(line;grid)   fo.writeln(line); // solved grid
	foreach(line;header) fo.writeln(line); // footer for reference
}

MaxNmins scanData(string filename) {
	import std.regex;
	auto s = readText(filename);
	auto ctr = ctRegex!(`(\d+),(\d+)`);
	auto data = MaxNmins(999,0,999,0); // initialize with high mins & low maxs
	foreach (c; matchAll(s, ctr)) {
		auto x = to!size_t(c[1]);
		auto y = to!size_t(c[2]);
		data.xmin = x < data.xmin ? x : data.xmin;
		data.xmax = x > data.xmax ? x : data.xmax;
		data.ymin = y < data.ymin ? y : data.ymin;
		data.ymax = y > data.ymax ? y : data.ymax;
	}
	return data;
}

string[] buildEmptyTextgrid() {
	enum padding = 3;
	auto xdim = padding + (maxAndmins.xmax - maxAndmins.xmin +1) + padding;
	auto ylength = maxAndmins.ymax + 1 + padding;
	// build one line of dots...i.e. an empty grid
	string dotline = replicate(".",xdim); // "..................."
	
	string[] resultStr;
	// make ylength number of 'empty' grid lines
	// .................
	// .................
	foreach(i;0..ylength) resultStr ~= dotline ~ format("-%03s",i);
	return resultStr;
}

string[] buildGridHeader() {
	enum padding = 3;
	auto xdim = padding + (maxAndmins.xmax - maxAndmins.xmin +1) + padding;
	string[] xStr;
	// make and array of 3-char strings that contain the x-axis values
	foreach(val;maxAndmins.xmin..maxAndmins.xmax+1) xStr ~= format("%3s",val);

	// build header with x values laid out vertically
	string[] hdr; hdr.length = 3;
	foreach(size_t i,ref line;hdr) {   // build ex.: "   ...4455...   "
		line = "   ";                  //            "   ...9900...   "
		foreach(x;xStr) line ~= x[i];  //            "   ...8901...   "
		line ~= "   ";
	}
	return hdr;
}

void readDataIntoGrid() {
	while(!f.eof()) {
		auto listOfNodes = f.readln.strip.split(" -> ");
		string[] xNy;
		size_t x1,y1, x2,y2;
		foreach(node;listOfNodes) {
			if(xNy.length == 0) { // first node in this string?
				xNy = node.split(",");
				x1 = to!size_t(xNy[0]);
				y1 = to!size_t(xNy[1]);
				continue;
			} else {
				xNy = node.split(",");
				x2 = to!size_t(xNy[0]);
				y2 = to!size_t(xNy[1]);
				placeGridBarriers(x1,x2,y1,y2); // a line of barriers
			}
			//x2,y2 become x1,y1 for next line of barriers
			x1=x2; y1=y2;
		}
	}
}

void placeGridBarriers(size_t x1,size_t x2, size_t y1, size_t y2) {
	// The supplied data may draw a line not just left to right
	// and top to bottom but also right to left and bottom to top.
	// The ternary expressions below normalize the supplied data
	// so the line will be drawn properly no matter how the x-y
	// indices are supplied.
	size_t xlow  = x1 > x2 ? x2 : x1;
	size_t xhigh = x1 > x2 ? x1 : x2;
	size_t ylow  = y1 > y2 ? y2 : y1;
	size_t yhigh = y1 > y2 ? y1 : y2;
	// draw the vertical or horizontal line of '#'s 
	foreach(x;xlow..xhigh+1) {
		foreach(y;ylow..yhigh+1) {
			placeGridChar("#",x,y);
		}
	}
}

void placeGridChar(string s, size_t x, size_t y) {
	size_t xi = x - maxAndmins.xmin + 3;
	// insert one '#' at the supplied coordinates
	grid[y] = grid[y][0..xi] ~ s ~ grid[y][xi+1..$];
}

void dumpTheSand() {
	bool allSandFallingThrough;
	size_t countSandDrops;
	while(!allSandFallingThrough) {
		size_t x = 500, y = 1; // sand unit starts here
		bool sandUnitCameToRest = false;
		while(!sandUnitCameToRest) {
			//write(" ",x,"-",y);
			// 1st) try to fall vertically straight down
			if(openGridLocation(x,y+1)) {
				y++;

			// 2nd) try to fall diagonally down to the left
			} else if(openGridLocation(x-1,y+1)) {
				x--; y++;

			// 3rd) try to fall diagonally down to the right
			} else if(openGridLocation(x+1,y+1)) {
				x++; y++;

			// sand is at rest; place a sand object, o, in the grid.
			} else {
				sandUnitCameToRest = true;
				placeGridChar("o",x,y);
				countSandDrops++;
			}

			if(y > maxAndmins.ymax) {
				allSandFallingThrough =  true;
				placeGridChar("X",x,y);
				break;
			}
		}
	}
	countSandDrops.writeln;
}

bool openGridLocation(size_t x, size_t y) {
	// rem we are using a condensed grid so we don't have to deal
	// with a large empty grid; hence, xi, here.
	size_t xi = x - maxAndmins.xmin + 3;
	return grid[y][xi] == '.' ? true : false;
}