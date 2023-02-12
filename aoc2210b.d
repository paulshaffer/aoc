module aoc2210b;

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
	string   cpuInstruction = instructionLine[0];
	cycleCnt++;

	if(cpuInstruction == "noop") {
		cpuReg[cycleCnt+1] = cpuReg[cycleCnt];

	} else {
		cpuReg[cycleCnt+1] = cpuReg[cycleCnt];
		cycleCnt++;
		long value = to!long(instructionLine[1]);
		cpuReg[cycleCnt+1] = cpuReg[cycleCnt] + value;
	}
}

string[6] screen;
for (cycleCnt = 1; cycleCnt <= 240; cycleCnt++) {
	auto pixelCnt = cycleCnt - 1;
	auto line    = pixelCnt/40;
	auto drawPos = pixelCnt%40;
	auto spriteCenterPos = cpuReg[cycleCnt];
	auto spriteLower = spriteCenterPos -1 >= 0 ? spriteCenterPos -1 : 0;
	auto spriteUpper = spriteCenterPos +1 <= 39 ? spriteCenterPos +1 : 39;

	if ((drawPos >= spriteLower) &&
		(drawPos <= spriteUpper)) 
		 screen[line] ~="#";
	else screen[line] ~=".";
}
foreach(line;screen) fo.writeln(line);

auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}