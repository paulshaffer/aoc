module aoc2212a3;

import std.stdio;
import std.string: strip, toUpper;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.algorithm;

struct Location {
	int row, col;
	Location opBinary(string op)(Location rhs) const if (op == "-") {
        return Location(row-rhs.row, col-rhs.col); // new object 
    }
}

struct Node {
	int movesFromStart;
	Location prevLoc;
	char height;
}

enum dataSetcolumns = 159;
enum dataSetrows = 41;
Node[dataSetcolumns][dataSetrows] grid;

File f;
File fo;

void main(string[] args) {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

	// INITIALIZE GRAPH
	// File f  = File("temp2.data");
	f  = File("aoc2212a.data");
	fo = File("tempout.data","w");
	Location startingNode, endingNode;
	int row=0, col=0;
	while(!f.eof()) {
		auto line = f.readln.strip;
		foreach(c;line) {
			grid[row][col].height = c; // read-in height data
			if (c == 'S') {
				grid[row][col].height = 'a';
				startingNode = Location(row, col);
			}
			if (c == 'E') {
				grid[row][col].height = 'z';
				endingNode = Location(row, col);
			}
			col++;
		}
		row++; col=0;
	}

	// Breadth First Search
	Location[] queue; queue ~= startingNode;
	while(	(queue.length > 0) &&
			(queue[0] != endingNode)  )
		{
		auto thisRow = queue[0].row;
		auto thisCol = queue[0].col;
		auto thisMoves = grid[thisRow][thisCol].movesFromStart;
		auto thisNodeHeight = grid[thisRow][thisCol].height;
		
		if(	(thisRow > 0) && 
			(grid[thisRow - 1][thisCol].movesFromStart == 0) && 
			(thisNodeHeight +1 >= grid[thisRow - 1][thisCol].height +0) )
		{
			queue ~= Location(thisRow - 1, thisCol);
			grid[thisRow - 1][thisCol].prevLoc = Location(thisRow, thisCol);
			grid[thisRow - 1][thisCol].movesFromStart = thisMoves + 1;
		}
		if(	(thisRow < dataSetrows -1) && 
			(grid[thisRow + 1][thisCol].movesFromStart == 0) && 
			(thisNodeHeight +1 >= grid[thisRow + 1][thisCol].height +0) )
		{
			queue ~= Location(thisRow + 1, thisCol);
			grid[thisRow + 1][thisCol].prevLoc = Location(thisRow, thisCol);
			grid[thisRow + 1][thisCol].movesFromStart = thisMoves + 1;
		}
		if(	(thisCol > 0) && 
			(grid[thisRow][thisCol - 1].movesFromStart == 0) && 
			(thisNodeHeight +1 >= grid[thisRow][thisCol - 1].height +0) )
		{
			queue ~= Location(thisRow, thisCol - 1);
			grid[thisRow][thisCol - 1].prevLoc = Location(thisRow, thisCol);
			grid[thisRow][thisCol - 1].movesFromStart = thisMoves + 1;
		}
		if(	(thisCol < dataSetcolumns -1) && 
			(grid[thisRow][thisCol + 1].movesFromStart == 0) && 
			(thisNodeHeight +1 >= grid[thisRow][thisCol + 1].height +0) )
		{
			queue ~= Location(thisRow, thisCol + 1);
			grid[thisRow][thisCol + 1].prevLoc = Location(thisRow, thisCol);
			grid[thisRow][thisCol + 1].movesFromStart = thisMoves + 1;
		}

		// since movesFromStart = 0 is a next-node search criteria, 
		// change the starting node ,'S', to -1 movesFromStart
		if(queue[0] == startingNode) grid[thisRow][thisCol].movesFromStart = -1;

		queue  = queue[1..$]; // pop first node off of queue; its no longer needed
	}

	// Extra work to explore whether or not there is more than one path equal
	// in moves to the shortest path
	//writeRouteArrows(endingNode, startingNode);
	//writeSolvedPath();



auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}

void writeRouteArrows(Location currNode, Location startingNode) {
	while (currNode != startingNode) {
		int prevRow = grid[currNode.row][currNode.col].prevLoc.row;
		int prevCol = grid[currNode.row][currNode.col].prevLoc.col;
		Location nodeDiff = currNode - grid[currNode.row][currNode.col].prevLoc;
		if(nodeDiff == Location(1,0)){
			grid[prevRow][prevCol].height = '|';
		} else if(nodeDiff == Location(-1,0)){
			grid[prevRow][prevCol].height = '^';
		} else if(nodeDiff == Location(0,1)){
			grid[prevRow][prevCol].height = '>';
		} else if(nodeDiff == Location(0,-1)){
			grid[prevRow][prevCol].height = '<';
		}
		currNode = Location(prevRow, prevCol);
	}
}

void writeSolvedPath() {
	for(size_t row=0; row < dataSetrows; row++) {
		for(size_t col=0; col < dataSetcolumns; col++) {
			fo.write(grid[row][col].height);
		}
		fo.writeln;
	}
}