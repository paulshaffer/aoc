﻿module aoc2216a;

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
string[ubyte] vlvUbyteToTextLookup;
ubyte[ubyte] unqRateToVlv;
size_t rT; // total of all flow rates
ubyte firstVlv = 1;
ubyte idByte;
Path currPath, bestPath;
size_t pathCount;
enum MAX_PATHS = 10_000_000;
Path[MAX_PATHS] allPaths;

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
	for(ubyte i=1; i <= (vlv.length); i++) fo.writefln("%2s %s %s",i,vlvUbyteToTextLookup[i],vlv[i]);
	// fo.writeln(firstVlv);
	// foreach(rate;unqRateToVlv.keys.sort) fo.writef("%s-%s  ",rate,unqRateToVlv[rate]);
	writeln(rT);
	// fo.writeln(unqRateToVlv.length);

	move(1, -1);

	pathCount.writeln;

	bool dupRate;
	ubyte[25] rates;
	for(size_t i=1; i<=pathCount; i++) {
		rates = 0;
		foreach(rate;allPaths[i].r) {
			if((rates[rate]) && (rate > 0)) {
				dupRate = true; break;
			} else {
				rates[rate] = 1;
			}
		}
		fo.writeln(allPaths[i]);
		if(dupRate) {
			writeln("Duplicate Rate");
			break;
		}
	}
	if(!dupRate) writeln("No duplicate rates.");

	
//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

struct Valve {
	ubyte rate = 0;
	ubyte[] nextVlvs;
	ubyte nextVlv = 0;
	byte i = -1;
	byte indexAtTopLevel;
	bool lastVlvOption = false;
	bool visited = false;

	void nextVlvOption() {
			i++;
			i = i >= nextVlvs.length ? 0 : i;
			nextVlv = nextVlvs[i];
		lastVlvOption = (i + 1 >= nextVlvs.length) ? true : false;
	}
}

struct Path {
	ubyte[30] p;
	ubyte[30] r;
	ushort[30] subt;
	byte totalRate;
	ushort total;
	string toString() const {
		string strP=" ",strR=" ",strS;
		foreach(size_t i, id; p) {
			if(id == 0) break;
			//fo.writeln(id);
			//fo.writeln(vlvUbyteToTextLookup[id]);
			strP = strP ~ vlvUbyteToTextLookup[id] ~ "  ";
			strR = strR ~ format("%2s  ",r[i]);
			strS = strS ~ format("%3s ",subt[i]);
		}
		string s1 = strP~"\n"~strR;//~"\n"~strS~"\n";
		// string s2 = format("total rate: %4s   total flow: %4s \n",totalRate,total);
		return s1; //~ s2;
	}
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
		vlvUbyteToTextLookup[idByte] = vlvID[1];
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
// call function 1st time with v=1, time = -1
void move(ubyte v, byte time) {
	time++;
	currPath.p[time] = v;
	currPath.r[time] = vlv[v].visited ? 0 : vlv[v].rate;
	Valve saveValveState = vlv[v];

	if(time < 28) {
		if(!vlv[v].visited) {
			vlv[v].visited = true;
			while(!vlv[v].lastVlvOption) {
				vlv[v].nextVlvOption();
				vlv[v].indexAtTopLevel = vlv[v].i;
				move(vlv[v].nextVlv, time);
			}
		} else { // vlv[v].visited && time < 28
			vlv[v].nextVlvOption();
			if(vlv[v].i != vlv[v].indexAtTopLevel) {
				while(vlv[v].i != vlv[v].indexAtTopLevel) {
					move(vlv[v].nextVlv, time);
					vlv[v].nextVlvOption();
				}
			} else {// vlv[v].i == vlv[v].indexAtTopLevel
				pathCount++;
				allPaths[pathCount] = currPath;
			}
		}
	} else if(time == 28) {
		pathCount++;
		allPaths[pathCount] = currPath;
	} else { //time > 28
		fo.writeln("Error.  Time > 28 minutes: time: ",time,"\n",currPath);
	}
	currPath.p[time] = 0;
	currPath.r[time] = 0;
	vlv[v] = saveValveState;
}

void optimizedCurrPath() {
	
}