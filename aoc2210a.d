module aoc2210a;

import std.stdio;
import std.string: strip, toUpper;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.math.algebraic;
import std.algorithm;


void main() {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

//auto f  = File("temp.data");
auto f  = File("aoc2210a.data");
auto fo = File("tempout.data","w");

enum instrCnt = 150;
enum maxCyclesPerInstr = 2;
long[instrCnt * maxCyclesPerInstr] cpuReg;
auto cycleCnt = 0;
cpuReg[0] = 1;
cpuReg[1] = 1;

while (!f.eof()) {
	string[] instructionLine = f.readln.strip.split;
	string   cpuInstruction =         instructionLine[0];
	
	cycleCnt++;

	if(cpuInstruction == "noop") {
		cpuReg[cycleCnt+1] = cpuReg[cycleCnt];
		fo.writefln("%s %3s %s",instructionLine,cycleCnt,cpuReg[cycleCnt]);

	} else {
		cpuReg[cycleCnt+1] = cpuReg[cycleCnt];
		cycleCnt++;
		long value = to!long(instructionLine[1]);
		cpuReg[cycleCnt+1] = cpuReg[cycleCnt] + value;
		fo.writefln("%s %3s %s",instructionLine,cycleCnt,cpuReg[cycleCnt]);
	}
}

long runningTotal;
for (int i=20; i<=220; i+=40) {
	runningTotal += i * cpuReg[i];
	fo.writefln("%3s x %6s: %s",i,cpuReg[i],runningTotal);
}


auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}