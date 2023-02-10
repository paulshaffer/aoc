module aoc2208b;

import std.stdio;
import std.string;
import std.array;
import std.conv: to;
import core.time: MonoTime;
import std.path;
import std.algorithm: sort;
import std.algorithm.searching: canFind, startsWith;
import std.range: repeat;

File f, fo;
string[] hgt; // tree height data string
byte[99][99] high; // tree height data value
TreeHouseView view, maxView;

byte lineNum;

ulong maxRow;
ulong maxCol;

void main(){
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

f = File("aoc2208a.data");
//f = File("temp.data");
fo= File("aoc2208bOut.data","w");
while(!f.eof) hgt ~= f.readln.strip; // read data

maxRow = hgt.length - 1;
maxCol = hgt[0].length - 1;

for(int row; row <= maxRow; row++) {
	for(int col; col <= maxCol; col++) {
		high[row][col] = to!byte(hgt[row][col] - '0'); } }

for(byte row; row <= maxRow; row++) {
	for(byte col; col <= maxCol; col++) {
		view.lookingLeft  = lookLeft (row, col);
		view.lookingRight = lookRight(row, col);
		view.lookingUp    = lookUp   (row, col);
		view.lookingDown  = lookDown (row, col);
		view.col = col; view.row = row;
		if(view.scenicScore > maxView.scenicScore) maxView = view; } }

writeln(maxView,"  scenic score : ",maxView.scenicScore);

// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}

struct TreeHouseView {
	int lookingLeft, lookingRight, lookingUp, lookingDown;
	byte row, col;

	int scenicScore(){
		return	lookingRight * lookingLeft *
				lookingDown * lookingUp;
	}
}

int lookLeft (int row, int col) {
	int look;
	byte thisHeight = high[row][col];

	if(col > 0) {
		for(int i = col-1; i >= 0; i--) {
			look = col - i;
			if(high[row][i] >= thisHeight) {
				break;
			} 
		}
	} else {look = 0;}

return look;
}
	
int lookRight (int row, int col) {
	int look;
	byte thisHeight = high[row][col];

	if(col < maxCol) {
		for(int i = col+1; i <= maxCol; i++) {
			look = i - col;
			if(high[row][i] >= thisHeight) {
				break;
			} 
		}
	} else {look = 0;}

return look;
}	

int lookUp (int row, int col) {
	int look;
	byte thisHeight = high[row][col];

	if(row > 0) {
		for(int i = row-1; i >= 0; i--) {
			look = row - i;
			if(high[i][col] >= thisHeight) {
				break;
			} 
		}
	} else {look = 0;}

return look;
}

int lookDown (int row, int col) {
	int look;
	byte thisHeight = high[row][col];

	if(row < maxRow) {
		for(int i = row+1; i <= maxRow; i++) {
			look = i - row;
			if(high[i][col] >= thisHeight) {
				break;
			} 
		}
	} else {look = 0;}

return look;
}	