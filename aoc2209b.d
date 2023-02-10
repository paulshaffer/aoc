module aoc2209b;

import std.stdio;
import std.string: strip, toUpper;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.math.algebraic;
import std.algorithm;

enum float knotlength = 2.0;

struct CartesianPoint {
	float x=0.0,y=0.0;
	int[string] log;

	void moveRelative(float a, float b, bool doLog) {
		if ("0 0" !in log) {log["0 0"]++;}
		x += a;
		y += b;
		if (doLog) log[toString]++; }

	string toString() const {return format("%s %s",x,y);}
}

struct Rope {
	CartesianPoint[10] knot;

	void moveHead(char cmd) {
		final switch (cmd) {
			case 'U':knot[0].moveRelative(0,1,false); break;
			case 'D':knot[0].moveRelative(0,-1,false); break;
			case 'R':knot[0].moveRelative(1,0,false); break;
			case 'L':knot[0].moveRelative(-1,0,false); break;
		}
		updateTail();
	}

	void updateTail() {
		for (int i = 1; i < knot.length; i++) {
			auto xDiff = knot[i-1].x - knot[i].x;
			auto yDiff = knot[i-1].y - knot[i].y;
			auto magDiff = sqrt((xDiff^^2) + (yDiff^^2));
			bool log = (i == 9) ? true : false;

			if (magDiff >= knotlength) {
				if (abs(xDiff) == knotlength) xDiff /= 2;
				if (abs(yDiff) == knotlength) yDiff /= 2;
				knot[i].moveRelative(xDiff,yDiff,log);
			} else break;
		}
	}
}


void main() {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

auto inputFile = File("aoc2209a.data");
Rope rope;

while (!inputFile.eof()) {
	auto moveCmd = inputFile.readln.strip.split;
	char direction  = moveCmd[0][0];
	int numOfSteps = to!int(moveCmd[1]);
	foreach (i; 0 .. numOfSteps) rope.moveHead(direction);
}

writeln("number of locations visited by the rope tail at least once : ",
		rope.knot[9].log.length);

auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}