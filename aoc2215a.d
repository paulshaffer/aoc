module aoc2215a;

import std.stdio;
import std.file: readText;
import std.conv: to;
import std.math: abs;
import std.traits;

import core.time: MonoTime;
// File fo;

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
	auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2215a.data";
	// fo = File("tempout.data","w");
	CommPair[] commPair;
	int[int] beaconsOnLineOfInterest;


	// read file that has data sets in the form of x,y coordinate pairs
	// for each sensor-beacon pair.  Create on array of structs to hold
	// this information.
	loadFileDataIntoArrayOfStructs(commPair, filename);
	
	int lineOfInterest = args.length > 1 ? to!int(args[2]) : 2_000_000;
	Span[] span; // A section of line-of-interest coordinates where
				 // no other beacons are present.
	foreach(size_t i,cp;commPair) {
		int distanceToLineOfInterest = abs(cp.sy - lineOfInterest);
		int manhattanDistance = cp.manhattanDistance();
		if(manhattanDistance >= distanceToLineOfInterest) {
			int plusMinusDist = manhattanDistance - distanceToLineOfInterest;
			int xLow  = cp.sx - plusMinusDist;
			int xHigh = cp.sx + plusMinusDist;
			span ~= Span(xLow,xHigh);

			// if a beacon is on the line-of-interest it is subtracted
			// from the total number of places a beacon can not be
			if(cp.by == lineOfInterest) beaconsOnLineOfInterest[cp.bx]++;
		}
	}

	// if spans overlap, combine them into a single span and mark
	// the other spans !inUse.
	bool combinedSpansThisCycle = true;
	while(combinedSpansThisCycle) {
		combinedSpansThisCycle = false;
		for(size_t i=0; i < span.length-1; i++) {
			if(!span[i].inUse) continue;
		
			for(size_t j=i+1; j < span.length; j++) {
				if(!span[j].inUse) continue;

				// if one span overlaps with the other, combine them into one span
				if(spanIContainedInSpanJ(span[i],span[j]) || spanJContainedInSpanI(span[i],span[j])) {
					span[i].xLow  = span[i].xLow  < span[j].xLow  ? span[i].xLow  : span[j].xLow;
					span[i].xHigh = span[i].xHigh > span[j].xHigh ? span[i].xHigh : span[j].xHigh;
					span[j].inUse = false;
					combinedSpansThisCycle = true;
				}
			}
		}
	}
	foreach(sp;span) if(sp.inUse) {
		writefln("%,d %,d +1 -%d = %,d",sp.xHigh,sp.xLow,beaconsOnLineOfInterest.length,sp.xHigh-sp.xLow+1-beaconsOnLineOfInterest.length);
	}


//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

struct CommPair {
	int sx,sy,bx,by;
	int manhattanDistance() {
		return abs(sx-bx) + abs(sy-by);
	}
}

void loadFileDataIntoArrayOfStructs(ref CommPair[] commPair, string filename) {
	import std.regex;
	auto s = readText(filename);
	auto ctr = ctRegex!(`x=(-*\d+), y=(-*\d+):.*x=(-*\d+), y=(-*\d+)`);
	CommPair cptemp;
	foreach (c; matchAll(s, ctr)) {
		cptemp.sx = to!int(c[1]);
		cptemp.sy = to!int(c[2]);
		cptemp.bx = to!int(c[3]);
		cptemp.by = to!int(c[4]);
		commPair ~= cptemp;
	}
}

struct Span {
	int xLow, xHigh;
	bool inUse = true;
}

bool spanIContainedInSpanJ (Span spanI, Span spanJ) {
	return 	(spanI.xLow >= spanJ.xLow && spanI.xLow <= spanJ.xHigh) ||
			(spanI.xHigh>= spanJ.xLow && spanI.xHigh<= spanJ.xHigh);
}

bool spanJContainedInSpanI (Span spanI, Span spanJ) {
	return 	(spanJ.xLow >= spanI.xLow && spanJ.xLow <= spanI.xHigh) ||
			(spanJ.xHigh>= spanI.xLow && spanJ.xHigh<= spanI.xHigh);
}