module aoc2204b;

import std.stdio;
import std.string: strip;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;

void main(){
	auto progStartTime = MonoTime.currTime;
	size_t elfOverlap, elfPairs;
	auto cleaningAssignments = File("aoc2204a.data","r");
	while(!cleaningAssignments.eof) {
		auto cleaningPairs = cleaningAssignments.readln.strip.split(",");
		++elfPairs;

		auto elf1AreasStrArray = cleaningPairs[0].split("-");
		byte[] elf1AreasByteArray = to!(byte[])(elf1AreasStrArray);
		auto e1Lower=elf1AreasByteArray[0]; auto e1Upper=elf1AreasByteArray[1];
		
		auto elf2AreasStrArray = cleaningPairs[1].split("-");
		byte[] elf2AreasByteArray = to!(byte[])(elf2AreasStrArray);
		auto e2Lower=elf2AreasByteArray[0]; auto e2Upper=elf2AreasByteArray[1];

		if	(((e1Upper >= e2Lower) && (e1Upper <= e2Upper)) ||
			 ((e2Upper >= e1Lower) && (e2Upper <= e1Upper)))
			 {++elfOverlap;}
		
		writefln("%4s %14s %4s",elfPairs,cleaningPairs,elfOverlap);
	}
	writeln(MonoTime.currTime - progStartTime);
}