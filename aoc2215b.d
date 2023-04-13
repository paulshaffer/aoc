module aoc2215b;

import std.stdio;
import std.file: readText;
import std.conv: to;
import std.math: abs;
import std.traits;

import core.time: MonoTime;
File fo;

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2215a.data";
	fo = File("tempout.data","w");
	CommPair[] commPair;


	// read file that has data sets in the form of x,y coordinate pairs
	// for each sensor-beacon pair.  Create on array of structs to hold
	// this information.
	loadFileDataIntoArrayOfStructs(commPair, filename);
	
	foreach(int lineOfInterest;0..4_000_000) {
		int[int] beaconsOnLineOfInterest;
		Span[] span; // A section of line-of-interest coordinates where
					// no other beacons are present.
		createSpansOfNoBeacons(lineOfInterest,commPair,span,beaconsOnLineOfInterest);

		// if spans overlap, combine them into a single span and mark
		// the other spans !inUse.
		combineOverlappingSpans(span);

		// look for a line that doesn't have 4,000,001 locations accounted for
		if(beaconFreeLocations(span) < 4_000_001) {
			fo.writeln(lineOfInterest);
			foreach(sp;span) if(sp.inUse) {
				fo.writeln(sp);
			}

			// find the location that is not accounted for
			foreach(ulong i;0..4_000_000) {
				bool found = false;
				foreach(sp;span) {
					if(i >= sp.xLow && i <= sp.xHigh) {
						found = true;
						break;
					}
				}
				if(!found) {
					fo.writeln("x= ",i,"   y= ",lineOfInterest);
					fo.writeln("tuning frequency ",i*4_000_000 + lineOfInterest);

				}
			}
		}
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

void createSpansOfNoBeacons(int lineOfInterest, CommPair[] commPair,ref Span[] span, ref int[int] beaconsOnLineOfInterest) {
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
}

void combineOverlappingSpans(ref Span[] span) {
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

					// after combining two spans, perform bounds checking
					// 15 part b limits the search between 0 and 4,000,000
					span[i].xLow  = span[i].xLow  < 0         ? 0         : span[i].xLow;
					span[i].xHigh = span[i].xHigh > 4_000_000 ? 4_000_000 : span[i].xHigh;
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

int beaconFreeLocations(ref Span[] span) {
	int noBeaconCount = 0;
	foreach(sp;span) if(sp.inUse) noBeaconCount += sp.xHigh - sp.xLow + 1;

	return noBeaconCount;
}