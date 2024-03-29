﻿module aoc2216a2;

import std.stdio;
import std.file;
import std.conv: to;
import std.string;
import std.algorithm: sort;
import std.algorithm.iteration: permutations;
import std.range: iota, repeat;
import std.array;
import std.traits;
import core.time: MonoTime;
import std.typecons;

File fo;
File f;
string filename;
Valve[ubyte] vlv;
ubyte[string] vlvTextToUbyteLookup;
string[ubyte] vlvUbyteToTextLookup;
ubyte[ubyte] unqRateToVlv;
ubyte[ubyte] zeroVlvs;
ubyte[ubyte] flowVlvs;
// ubyte[ubyte] sourceVlvs;

size_t rT; // total of all flow rates
ubyte firstVlv = 1;
ubyte idByte;
int[60][60] timeCost;


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
	writeln("Total of all valve rates: ",rT);

	if(allGraphEdgesBidirectional) {
		writeln("All edges are bidirectional.  Graph is undirected.");
	} else {
		writeln("Some graph edges are unidirectional");
	}

	fillTimeCostTable();

	printTimeCostTable();

	eliminateZeroRateValves();
	// for(ubyte i = 1; i<=vlv.length; i++) timeCost[i][i] = 99;

	fo.writeln("\n");

	auto sourceVlvs = flowVlvs.dup;
	sourceVlvs[1] = 1;
	fo.writeln(sourceVlvs);
	foreach(fromVlv;sourceVlvs) {
		foreach(toVlv;sourceVlvs) {
			if(fromVlv == toVlv) continue;
			if(timeCost[fromVlv][toVlv] == 0) timeCost[fromVlv][toVlv] = 999;
		}
	}

	printTimeCostTable2();

	fo.write("\nFlow Valves: ");
	foreach(key;flowVlvs.keys.sort) if(flowVlvs[key]) fo.writef("%3s",key);
	fo.write("\nZero Valves: ");
	foreach(key;zeroVlvs.keys.sort) if(zeroVlvs[key]) fo.writef("%3s",key);
	fo.writeln();

	fo.writeln("timeCost table is symetrical: ",isSymetrical);

	shortestPathBetweenEachPairOfNodes();

	//writeln(iota(1,5,1).permutations);

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
			flowVlvs[idByte] = 1;
			if(vlvRate !in unqRateToVlv) {
				unqRateToVlv[vlvRate] = idByte;
			} else {
				writeln("Valve flow rates are not unique values.");
			}
		 } else {
			zeroVlvs[idByte] = 1;
		 }
	}
}

bool allGraphEdgesBidirectional() {
	bool bidirectional = false;
	for(ubyte currVlv=1; currVlv <= vlv.length; currVlv++) {
		foreach(nextVlv;vlv[currVlv].nextVlvs) {
			foreach(thisVlv;vlv[nextVlv].nextVlvs) {
				if(thisVlv == currVlv) {
					bidirectional = true; break;
				} else {
					bidirectional = false;
				}
			}
			if(!bidirectional) break;
		}
		if(!bidirectional) break;
	}
	return bidirectional;
}

void fillTimeCostTable() {
	for(ubyte fromVlv=1; fromVlv <= vlv.length; fromVlv++) {
		foreach(toVlv;vlv[fromVlv].nextVlvs) {
			timeCost[fromVlv][toVlv] = 1;
			//timeCost[toVlv][fromVlv] = 1;
		}
	}
}

void printTimeCostTable() {
	string header = "   ";
	foreach(num;iota(1,vlv.length+1,1)) {
		// if((cast(ubyte) num !in zeroVlvs) || (num == 1))
		header ~= format("%3s",num);
	}
	fo.writeln(header);
	fo.writeln(repeat('-',177));
	for(ubyte fromVlv=1; fromVlv <= vlv.length; fromVlv++) {
		// if((fromVlv in zeroVlvs) && (fromVlv != 1)) continue;
		fo.writef("%2s>",fromVlv);
		for(ubyte toVlv=1; toVlv <= vlv.length; toVlv++) {
			// if((toVlv in zeroVlvs) && (toVlv != 1)) continue;
			fo.writef("%3s",timeCost[fromVlv][toVlv]);
		}
		fo.writefln(" <%2s",fromVlv);
		if((fromVlv%10 == 0) && (fromVlv != vlv.length)) {
			fo.writeln(repeat('-',177));
		}
	}
	fo.writeln(repeat('-',177));
	fo.writeln(header);
}

void printTimeCostTable2() {
	string header = "   ";
	foreach(num;iota(1,vlv.length+1,1)) {
		if((cast(ubyte) num !in zeroVlvs) || (num == 1))
		header ~= format("%3s",num);
	}
	fo.writeln(header);
	fo.writeln(repeat('-',((flowVlvs.length+1)*3)+7));
	for(ubyte fromVlv=1; fromVlv <= vlv.length; fromVlv++) {
		if((fromVlv in zeroVlvs) && (fromVlv != 1)) continue;
		fo.writef("%2s>",fromVlv);
		for(ubyte toVlv=1; toVlv <= vlv.length; toVlv++) {
			if((toVlv in zeroVlvs) && (toVlv != 1)) continue;
			fo.writef("%3s",timeCost[fromVlv][toVlv]);
		}
		fo.writefln(" <%2s",fromVlv);
	}
	fo.writeln(repeat('-',((flowVlvs.length+1)*3)+7));
	fo.writeln(header);
}

void eliminateZeroRateValves() {
	// find a zero rate valve
	foreach(ubyte zeroVlv; zeroVlvs.keys.sort) {
		if(zeroVlv == 1) continue;

		for(ubyte tableRow = 1; tableRow <= vlv.length; tableRow++) {
			if(tableRow == zeroVlv) continue;

			// if no ref to this zero valve in this row go for another row
			if(timeCost[tableRow][zeroVlv] == 0) continue;

			fo.writeln(zeroVlv," ",vlv[zeroVlv]," tr=",tableRow," tC[",tableRow,"][",zeroVlv,"]=",timeCost[tableRow][zeroVlv]);
			for(ubyte toVlv = 1; toVlv <= vlv.length; toVlv++) {
				if(tableRow == toVlv) continue;
				if(timeCost[zeroVlv][toVlv] == 0) continue;
				if((timeCost[tableRow][toVlv] > timeCost[tableRow][zeroVlv] + timeCost[zeroVlv][toVlv]) ||
					(timeCost[tableRow][toVlv] == 0)) {
					timeCost[tableRow][toVlv] = timeCost[tableRow][zeroVlv] + timeCost[zeroVlv][toVlv];
				}
			}
			timeCost[tableRow][zeroVlv] = 0;
		}
		for(ubyte toVlv = 1; toVlv <= vlv.length; toVlv++) timeCost[zeroVlv][toVlv] = 0;
		//if(zeroVlv == 6) break;
	}
}

bool isSymetrical() {
	bool result = false;
	for(ubyte row =1; row <= vlv.length; row++) {
		for(ubyte col =1; col <= vlv.length; col++) {
			if(timeCost[row][col] != timeCost[col][row]) return result;
		}
	}
	result = true;
	return result;
}

void shortestPathBetweenEachPairOfNodes() {

	struct Vlv {ubyte num; ubyte dist;}
	Vlv[] vlvs;
	bool[60][60] visited;
	
	auto sourceVlvs = flowVlvs.dup;
	sourceVlvs[1] = 1;
	fo.writeln(sourceVlvs);

	foreach(fromVlv;sourceVlvs) {
		foreach(toVlv;sourceVlvs) {
			if(fromVlv == toVlv) continue;
			if(timeCost[fromVlv][toVlv] == 0) {
				timeCost[fromVlv][toVlv] = 999;
			}
		}
	}
	printTimeCostTable2();



	// foreach(srcVlv;sourceVlvs.keys.sort) {
	// 	vlvs ~= Vlv(srcVlv, 0);
	// 	while(vlvs.length > 0) {
	// 		foreach(toVlv;sourceVlvs.keys.sort) {
	// 			if(toVlv == srcVlv) continue;
	// 			if(timeCost[vlvs[0].num][toVlv] == 0) continue;
	// 			if(timeCost[vlvs[0].num][toVlv] + vlvs[0].dist < 
	// 				timeCost[srcVlv][toVlv]) {
	// 				timeCost[srcVlv][toVlv] = timeCost[vlvs[0].num][toVlv] + vlvs[0].dist;
	// 			}
	// 		}

	// 	}
	// }
}
//	1. start with node 1 and find the shortest path to each other node
//	then iterate through the remaining nodes.
//		2. using node number and DISTANCE to this node add nodes to visit
//		to the queue (queue will have current distance and node number);
// 		update the timeCost table with this nodes DISTANCE and mark node
// 		visited;
// 		3. if there are more nodes on the queue, pull one off.