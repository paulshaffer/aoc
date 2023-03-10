module aoc2211b;

import std.stdio;
import std.string: strip, toUpper;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.algorithm;

Monkey[] monkeys;
int rounds = 1;
int divisor = 1;

void main(string[] args) {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

if(args.length > 1) {
	rounds = to!int(args[1]);
	divisor = args.length == 3 ? to!int(args[2]) : 1;
}

// load throw data into structs
loadThrowData();
divisor = getTestDivisorProduct();
// ## rounds of throws
foreach(int i;1..rounds+1) {
	foreach(ref monkey;monkeys) {
		monkey.tossItems;
	}
}

//PRINT RESULTS
// print items held after last round
foreach(monkey;monkeys) write(monkey.items);
writeln;

// print toss counts
long maxTosses, nextMaxTosses;
foreach(size_t i,monkey;monkeys) {
	write(monkey.tossCnt," ");
	if(monkey.tossCnt > maxTosses) {
		nextMaxTosses = maxTosses;
		maxTosses = monkey.tossCnt;
	} else if (monkey.tossCnt > nextMaxTosses) {
		nextMaxTosses = monkey.tossCnt;
	}
}
writeln;
writeln("monkey business ",maxTosses * nextMaxTosses);

auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}



void loadThrowData() {
auto f  = File("aoc2211a.data");
//auto f  = File("temp.data");

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

int getTestDivisorProduct() {
	int result = 1;
	foreach(monkey;monkeys) {
		result *= monkey.divisorTest;
	}
	return result;
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

			items[0] %= divisor;

			// divisor test to determine where item will be thrown
			if(items[0] % divisorTest) {
				monkeys[thisMonkeyIfFalse].items ~= items[0];
			} else {
				monkeys[thisMonkeyIfTrue ].items ~= items[0];
			}
		}
	}
}