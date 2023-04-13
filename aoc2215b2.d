module aoc2215b2;

import std.stdio;
import std.file: readText;
import std.conv: to;
import std.math: abs;
import std.traits;
import std.parallelism;
import std.range;
import core.time: MonoTime;

enum MAX_SPANS = 50;

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2215a.data";
	CommPair[] commPair;
	ulong x,y;

	// read file that has data sets in the form of x,y coordinate pairs
	// for each sensor-beacon pair.  Create on array of structs to hold
	// this information.
	loadFileDataIntoArrayOfStructs(commPair, filename);
	
	foreach(int lineOfInterest;parallel(iota(0,4_000_001))) {
		Span[MAX_SPANS] span; // A section of line-of-interest coordinates where no other beacons are present.
		size_t index = 0;
		createSpansOfNoBeacons(lineOfInterest,commPair,span,index);

		// if spans overlap, combine them into a single span and mark
		// the other spans !inUse.
		combineOverlappingSpans(span,index);

		// look for a line that doesn't have 4,000,001 locations accounted for
		// if there is more than one span, then there is a span gap.
		if(spansCount(span,index) > 1) {

			// find the location that is not accounted for
			// AOC day 15 part b says there only one beacon so
			// either of two spans can tell us the missing 'x'
			foreach(sp;span) {
				if(sp.inUse) {
					if(sp.xLow == 0) {
						x = sp.xHigh + 1;
					} else {
						x = sp.xLow - 1;
					}

					y = lineOfInterest;
					break;
				}
			}
		}
	}
writeln(x," ",y);

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



struct CommPair {
	int sx,sy,bx,by;
	int manhattanDistance;
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
		cptemp.manhattanDistance = abs(cptemp.sx-cptemp.bx) + abs(cptemp.sy-cptemp.by);
		commPair ~= cptemp;
	}
}

struct Span {
	int xLow, xHigh;
	bool inUse = true;
}

void createSpansOfNoBeacons(int lineOfInterest, CommPair[] commPair, ref Span[MAX_SPANS] span, ref size_t index) {
	foreach(cp;commPair) {
		int distanceToLineOfInterest = abs(cp.sy - lineOfInterest);
		if(cp.manhattanDistance >= distanceToLineOfInterest) {
			int xLow  = cp.sx - (cp.manhattanDistance - distanceToLineOfInterest);
			int xHigh = cp.sx + (cp.manhattanDistance - distanceToLineOfInterest);
			span[index] = Span(xLow,xHigh); index++;
		}
	}
}

void combineOverlappingSpans(ref Span[MAX_SPANS] span, size_t index) {
	bool combinedSpansThisCycle = true;
	while(combinedSpansThisCycle) {
		combinedSpansThisCycle = false;
		for(size_t i=0; i < index-1; i++) {
			if(!span[i].inUse) continue;
		
			for(size_t j=i+1; j < index; j++) {
				if(!span[j].inUse) continue;

				// if one span overlaps with the other, combine them into one span
				if(spanIContainedInSpanJ(span[i],span[j]) || spanJContainedInSpanI(span[i],span[j])) {
					if(span[i].xLow  < span[j].xLow ) {
						span[i].xLow = span[i].xLow < 0 ? 0 : span[i].xLow;
					} else {
						span[i].xLow = span[j].xLow < 0 ? 0 : span[j].xLow;
					}

					if(span[i].xHigh > span[j].xHigh) {
						span[i].xHigh = span[i].xHigh > 4_000_000 ? 4_000_000 : span[i].xHigh;
					} else {
						span[i].xHigh = span[j].xHigh > 4_000_000 ? 4_000_000 : span[j].xHigh;
					}

					span[j].inUse = false;
					combinedSpansThisCycle = true;
				}
			}
		}
	}
}

bool spanIContainedInSpanJ (Span spanI, Span spanJ) {
	return 	(spanI.xLow >= spanJ.xLow && spanI.xLow <= spanJ.xHigh) ||
			(spanI.xHigh>= spanJ.xLow && spanI.xHigh<= spanJ.xHigh);
}

bool spanJContainedInSpanI (Span spanI, Span spanJ) {
	return 	(spanJ.xLow >= spanI.xLow && spanJ.xLow <= spanI.xHigh) ||
			(spanJ.xHigh>= spanI.xLow && spanJ.xHigh<= spanI.xHigh);
}

int spansCount(ref Span[MAX_SPANS] span, size_t index) {
	int spansCount = 0;
	foreach(size_t i,sp;span) {
		if(i<index) {
			if(sp.inUse) spansCount++;
		}
	}
	return spansCount;
}