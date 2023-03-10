module aoc2212a;

import std.stdio;
import std.string: strip, toUpper;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.algorithm;

struct Location {
	size_t row, col;
}

struct Node {
	int movesFromStart;
	Location prevLoc;
	char height;
}

enum dataSetcolumns = 159;
enum dataSetrows = 41;
Node[dataSetcolumns][dataSetrows] grid;

void main(string[] args) {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

	// INITIALIZE GRAPH
	// File f  = File("temp2.data");
	File f  = File("aoc2212a.data");
	File fo = File("tempout.data","w");
	Location startingNode, endingNode;
	size_t row;
	while(!f.eof()) {
		auto line = f.readln.strip; 
		foreach(size_t col,c;line) {
			fo.write(" ",row,"-",col);
			grid[row][col].height = c; // read-in height data
			
			if (c == 'S') {
				grid[row][col].height = 'a';
				startingNode = Location(row, col);
			}
			if (c == 'E') {
				grid[row][col].height = 'z';
				endingNode = Location(row, col);
			}
		}
		row++;
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


queue[0].writeln;
grid[queue[0].row][queue[0].col].writeln;


auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}