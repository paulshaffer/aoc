module aoc2208a;

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
byte[99][99] vis; // tree visibility data
byte lineNum;
ushort visCnt; // count of visible trees
ushort zeros;  // count of invisible trees

//bit map for the byte[][] vis array
enum Tb = 0x1; //0000 0001b turn on this bit for T-op to b-tm vis
enum Bt = 0x2; //0000 0010b turn on this bit for B-tm to t-op vis
enum Lr = 0x4; //0000 0100b turn on this bit for L-eft to r-ight vis
enum Rl = 0x8; //0000 1000b turn on this bit for R-ight to l-eft vis
enum LengthAndWidth = 99; //length and width of data set
enum maxRow = LengthAndWidth -1;
enum maxCol = LengthAndWidth -1;

void main(){
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

f = File("aoc2208a.data");
fo= File("aoc2208aOut.data","w");
while(!f.eof) hgt ~= f.readln.strip; // read data

// - convert each char digit of 'hgt' array to a numeric
//     value and push that value into byte[][] 'high' array
for(int row; row <= maxRow; row++) {
	for(int col; col <= maxCol; col++) {
		high[row][col] = to!byte(hgt[row][col] - '0'); } }

// looking left to right row by row
byte highestTreeThusFar;
for(int row = 0; row <= maxRow; row++) {
	highestTreeThusFar = -1; // 1st col is always visible
	for(int col = 0; col <= maxCol; col++) {
		if(high[row][col] > highestTreeThusFar) {
		// this tree is higher than all previous trees
		// and is, therefor, visible
			highestTreeThusFar = high[row][col];
			vis[row][col] |= Lr;
		} }	}

// looking right to left row by row
for(int row = 0; row <= maxRow; row++) {
	highestTreeThusFar = -1; // 1st col is always visible
	for(int col = maxCol; col >= 0; col--) {
		if(high[row][col] > highestTreeThusFar) {
		// this tree is higher than all previous trees
		// and is, therefor, visible
			highestTreeThusFar = high[row][col];
			vis[row][col] |= Rl;
		} }	}

// looking top to bottom column by column
for(int col = 0; col <= maxCol; col++) {
	highestTreeThusFar = -1; // 1st row is always visible
	for(int row = 0; row <= maxRow; row++) {
		if(high[row][col] > highestTreeThusFar) {
		// this tree is higher than all previous trees
		// and is, therefor, visible
			highestTreeThusFar = high[row][col];
			vis[row][col] |= Tb;
		} }	}

// looking bottom to top column by column
for(int col = 0; col <= maxCol; col++) {
	highestTreeThusFar = -1; // 1st row is always visible
	for(int row = maxRow; row >= 0; row--) {
		if(high[row][col] > highestTreeThusFar) {
		// this tree is higher than all previous trees
		// and is, therefor, visible
			highestTreeThusFar = high[row][col];
			vis[row][col] |= Bt;
		} }	}

// print visibility tree data
printArray(vis);

// print total visible trees
visCnt = countVisibleTrees();
fo.writefln("%s + %s = %s-%s",visCnt, zeros, visCnt+zeros, 99*99);

// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}

ushort countVisibleTrees() {
ushort cnt;
for(int row; row <= maxRow; row++) {
	for(int col; col <= maxCol; col++) {
		cnt   += vis[row][col]  > 0 ? 1 : 0 ;
		zeros += vis[row][col] == 0 ? 1 : 0 ;
	}
}
writeln(zeros);
return cnt;
}

void printArray (byte[99][99] arr){
for(int row; row <= maxRow; row++) {
	//for(int col; col <= maxCol; col++) fo.writef("%1X",high[row][col]);
	//fo.writeln();
	for(int col; col <= maxCol; col++) fo.writef("%1X", vis[row][col]);
	fo.writeln();
	} }