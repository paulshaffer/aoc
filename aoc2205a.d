module aoc2205a;

import std.stdio;
import std.string: strip;
import std.array: split;
import std.conv: to;
import std.algorithm.mutation: reverse;
import std.range: transposed;
import core.time: MonoTime;

char[][] stacks;
enum stackSpacing = 4;

void main(){
	auto progStartTime = MonoTime.currTime;
//++++++++++++++++++++++++++++++++++++++++++++

	auto ContainerStacksDataFile = File("aoc2205a.data","r");
	// read container stacks by line	    [A] [B] 
	//									[z]     [P]    etc.
	readContainerDataByRow(stacks, ContainerStacksDataFile);
	
	// transpose container matrix i.e.	Z 
	//									 A
	//									PB
	transposeStripReverse(stacks);

	while (!ContainerStacksDataFile.eof) {

		//ex: move 2 from 4 to 6
		auto moveC = ContainerStacksDataFile.readln.strip.split(" ");
		// ["move", "2", "from", "4", "to", "6"]
		auto moveQty = to!int(moveC[1]); // "2"
		auto fromSt  = to!int(moveC[3]); // "4"
		auto toSt    = to!int(moveC[5]); // "6"
		//writefln("move %2s from %2s to %2s",moveQty, fromSt, toSt);
		moveContainer(stacks, moveQty, fromSt, toSt);

	}

	writeln(stacks);
	foreach(stack;stacks[1..$]) write(stack[$-1]);
	writeln;

//++++++++++++++++++++++++++++++++++++++++++++
	writeln(MonoTime.currTime - progStartTime);
}

void readContainerDataByRow(ref char[][] stax, ref File ContainerStacks) {
	stax ~= "ignoreRowZero".dup;
	while(true) {
		char[] parsed = "".dup;
		auto stacksReadRow = cast(char[]) ContainerStacks.readln;
		if (stacksReadRow[1]== '1') {
			// read the empty line in the data file
			stacksReadRow = cast(char[]) ContainerStacks.readln;
			break;
		}
		for (size_t stackNum = 1; stackNum <= 9; ++stackNum){
			parsed ~= stacksReadRow[(stackNum * stackSpacing) - 3];
		}
		stax ~= parsed;
	}
}

void transposeStripReverse(ref char[][] stax) {
	auto tr = stax[1..$].transposed; stax.length = 1;
	foreach(row;tr) {
		//writeln(row);
		stax ~= row.to!(char[]).strip.reverse;
	}
}

void moveContainer(ref char[][] stax, int moveQty, int fromSt, int toSt) {
	if (stax[fromSt].length >= moveQty) {
		//writeln(stax[fromSt]," ",stax[toSt]);

		for(int i=1; i<=moveQty; ++i) {
			//writeln(i," ",stax[fromSt]," ",stax[toSt]);
			stax[toSt] ~= stax[fromSt][$ - 1];
			stax[fromSt].length -= 1;
			//writeln(i," ",stax[fromSt]," ",stax[toSt]);
		}

		//writeln(stax[fromSt]," ",stax[toSt]);
		//writeln("move complete");

	} else {
		writeln(" error1");
	}
}