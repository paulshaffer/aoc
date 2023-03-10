module aoc2211a;

import std.stdio;
import std.string: strip, toUpper;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.algorithm;

Monkey[] monkeys;

void main() {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

// load throw data into structs
loadThrowData();

// 20 rounds of throws
foreach(int i;1..21) {
	foreach(ref monkey;monkeys) monkey.tossItems;
}

//PRINT RESULTS
// print items held after last round
foreach(monkey;monkeys) writeln(monkey.items);

// print formatted toss counts
long topCnt, nextbestCnt;
foreach(size_t i,monkey;monkeys) {
	writeln("Monkey ",i," tosses: ",monkey.tossCnt);
	// while foreach-ing to print, calc two largest toss cnts
	if(monkey.tossCnt > topCnt) {
		nextbestCnt = topCnt;
		topCnt = monkey.tossCnt;
	} else if (monkey.tossCnt > nextbestCnt) {
		nextbestCnt = monkey.tossCnt;
	}
}
writeln("max tosses ",topCnt," x next highest tosses ",nextbestCnt," = ",topCnt*nextbestCnt);

auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}

void loadThrowData() {
auto f  = File("aoc2211a.data");

int i;
while(!f.eof()) {
	monkeys ~= Monkey();

	auto s1 = f.readln; // read "Monkey #:" and throw away

	// read array of strings of items "12 34 56 ..etc"
	auto s2 = f.readln.split(":")[1].strip.split(", ");
	foreach(ss;s2) monkeys[i].items ~= to!size_t(ss);
	
	// read "Operation new = old * #""
	auto s3 = f.readln.split(" = old ")[1].strip.split;
	// parse into operation and value
	monkeys[i].op    = s3[1] == "old" ? "square" : s3[0];
	monkeys[i].opVal = s3[1] == "old" ? 0 : to!size_t(s3[1]);

	// read these lines and convert to decimal values
	monkeys[i].divisorTest       = f.readln.split("by"     )[1].strip.to!size_t;
	monkeys[i].thisMonkeyIfTrue  = f.readln.split("monkey ")[1].strip.to!size_t;
	monkeys[i].thisMonkeyIfFalse = f.readln.split("monkey ")[1].strip.to!size_t;
	
	// should be a new line here to read and throw away
	s1 = f.readln;

	i++; 
}
}

struct Monkey {
	size_t[] items;
	string op;
	size_t opVal;
	size_t divisorTest;
	size_t thisMonkeyIfTrue;
	size_t thisMonkeyIfFalse;
	size_t tossCnt;

	void tossItems() {
		for(;items.length>0;items = items[1..$]) {
			tossCnt++;
			// main operation
			final switch (op) {
				case "+": items[0] += opVal; break;
				case "-": items[0] -= opVal; break;
				case "*": items[0] *= opVal; break;
				case "/": items[0] /= opVal; break;
				case "square": items[0] = items[0] * items[0];
			}
			// post inspection /3
			items[0] /= 3;

			// divisor test to determine where item will be thrown
			if(items[0] % divisorTest) {
				monkeys[thisMonkeyIfFalse].items ~= items[0];
			} else {
				monkeys[thisMonkeyIfTrue ].items ~= items[0];
			}
		}
	}
}