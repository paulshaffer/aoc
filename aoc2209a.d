module aoc2209a;

import std.stdio;
import std.string: strip, toUpper;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.math.algebraic;

enum float ropelength = 2.0;

struct CartesianPoint {
	float x,y;
	int[string] log;

	void moveRelative(float a, float b) {
		if ("0 0" !in log) {log["0 0"]++;}
		x += a;
		y += b;
		log[toString]++; }

	string toString() const {return format("%s %s",x,y);}
}

struct Vector {
	float x=0.0, y=0.0;
	float magnitude;
}
struct Rope {
	CartesianPoint head, tail;
	Vector moveVector;
	void moveHead(char cmd) {
		final switch (cmd) {
			case 'U': head.moveRelative(0,1); break;
			case 'D': head.moveRelative(0,-1); break;
			case 'R': head.moveRelative(1,0); break;
			case 'L': head.moveRelative(-1,0); break;
		}
		updateTail();
	}
	void updateTail() {
		moveVector.x = head.x - tail.x;
		moveVector.y = head.y - tail.y;
		if (abs(moveVector.x) == ropelength) {
			moveVector.x /= 2;
			tail.moveRelative(moveVector.x,moveVector.y);
		}
		if (abs(moveVector.y) == ropelength) {
			moveVector.y /= 2;
			tail.moveRelative(moveVector.x,moveVector.y);
		}
	}
}


void main() {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

auto inputFile = File("aoc2209a.data");

auto rope = Rope(CartesianPoint(0.0, 0.0),CartesianPoint(0.0, 0.0));

while (!inputFile.eof()) {
	auto moveCmd = inputFile.readln.strip.split;
	char direction  = moveCmd[0][0];
	int numOfSteps = to!int(moveCmd[1]);
	foreach (i; 0 .. numOfSteps) rope.moveHead(direction);
}

rope.tail.log.length.writeln;

auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}

