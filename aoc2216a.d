module aoc2216a;

import std.stdio;
import std.file;
import std.conv: to;
import std.string;
import std.algorithm: sort;
import std.array;
import std.traits;
import core.time: MonoTime;

File fo;
File f;
string filename;
Valve[ubyte] vlv;
ubyte[string] vlvTextToUbyteLookup;
ubyte[ubyte] unqRateToVlv;
size_t rT; // total of all flow rates
ubyte firstVlv = 1;
ubyte idByte;
// ubyte time;
Path currPath, bestPath;

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	filename = args.length > 1 ? args[1] : "aoc2216a.data";
	f  = File(filename);
	fo = File("tempout.data","w");


	// read lines of...
	// "Valve YK has flow rate=0; tunnels lead to valves GL, FT,..etc"
	loadFileDataIntoValve_aa();
	// for(ubyte i=1; i <= (vlv.length); i++) fo.writeln(i," ",vlv[i]);
	// fo.writeln(firstVlv);
	// foreach(rate;unqRateToVlv.keys.sort) fo.writef("%s-%s  ",rate,unqRateToVlv[rate]);
	// fo.writeln("\n",rT);
	// fo.writeln(unqRateToVlv.length);
	fo.writeln(vlv[14]);
	vlv[14].nextVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].nextVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].nextVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].nextVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].nextVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].nextVlvOption;
	fo.writeln(vlv[14]);

	vlv[14].visited = true;
		fo.writeln(vlv[14]);
	// vlv[14].resetVlvPath;
	fo.writeln(vlv[14]);
	vlv[14].prevVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].prevVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].prevVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].prevVlvOption;
	fo.writeln(vlv[14]);
	vlv[14].prevVlvOption;
	fo.writeln(vlv[14]);




//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

struct Valve {
	ubyte rate = 0;
	ubyte[] nextVlvs;
	ubyte nextVlv = 0;
	private byte i = -1;
	bool lastVlvOption = false;
	bool visited = false;

	void nextVlvOption() {
		if(i + 1 < nextVlvs.length) {
			i++;
			nextVlv = nextVlvs[i];
		}
		lastVlvOption = (i + 1 >= nextVlvs.length) ? true : false;
	}

	void prevVlvOption() {
		if(i > 0) {
			i--;
			nextVlv = nextVlvs[i];
		}
	lastVlvOption = false;
	}

	void resetVlvPath() {
		nextVlv = 0;
		i = -1;
		lastVlvOption = false;
		visited = false;
	}
}

struct Path {
	byte[30] p;
	byte[30] r;
	ushort[30] subt;
	byte totalRate;
	ushort total;
}

void loadFileDataIntoValve_aa() {
	import std.regex: ctRegex, matchAll, split;

	// create a string id to ubyte id lookup table
	auto s1  = readText(filename);
	auto ctr = ctRegex!(`Valve ([A-Z]{2})`);
	idByte = 0;
	foreach(vlvID;matchAll(s1,ctr)) {
		idByte++;
		vlvTextToUbyteLookup[vlvID[1]] = idByte;
	}
	//fo.writeln(vlvTextToUbyteLookup);

	auto ctr0 = ctRegex!(`; tunnels* leads* to valves*`);
	auto ctr1 = ctRegex!(`([A-Z]{2}).*=(\d+)`);
	auto ctr2 = ctRegex!(`([A-Z]{2})`);
	idByte = 0;
	while(!f.eof()) {

		// s2[0] contains the valve id and rate
		// s2[1] contains the list of next valves
		auto s2 = f.readln.strip.split(ctr0);

		// add a Valve to aa valve array; the key is the valve id
		// i.e. vlv[id] = ubyte rate
		auto m0 = matchAll(s2[0],ctr1);
		auto id = m0.front[1];
		ubyte vlvRate = to!ubyte(m0.front[2]);
		idByte++; // start idByte with 1
		vlv[idByte] = Valve(vlvRate);
		
		// fill Valve struct with nextVlvs
		foreach(m1;matchAll(s2[1],ctr2)) {
			vlv[idByte].nextVlvs ~= vlvTextToUbyteLookup[m1.front];
		}
		// calc total rate
		rT += vlvRate;

		// create a rate-to-valve-id lookup and test if each flow rate
		// is a unique value
		 if(vlvRate > 0) {
			if(vlvRate !in unqRateToVlv) {
				unqRateToVlv[vlvRate] = idByte;
			} else {
				writeln("Valve flow rates are not unique values.");
			}
		 }
	}
}

void move(ubyte v, ubyte time) {
	time++;
	currPath.p[time] = v;
	currPath.r[time] = vlv[v].visited ? 0 : vlv[v].rate;
	vlv[v].visited = true;

	if(time < 28) {
		for(; vlv[v].i < vlv[v].nextVlvs.length; vlv[v].i++) {

			// move(vlv[v].nextVlvs[vlv[v]]);
		}

	} else if( time == 28) {

	} else { //time > 28
		fo.writeln("Error.  Time > 28 minutes.");
	}
}
