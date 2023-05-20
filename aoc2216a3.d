module aoc2216a3;

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
ubyte[string] vlvTextToUbyteLookup;
string[ubyte] vlvUbyteToTextLookup;
ubyte[ubyte] vlvToRate;
ubyte[ubyte] zeroVlvs;
ubyte[ubyte] flowVlvs;
// ubyte[ubyte] sourceVlvs;

ubyte firstVlv = 1;
ubyte vlvNum;
ubyte[60][60] timeCost;


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

	fillTableWith99();

	if(allGraphEdgesBidirectional) {
		writeln("All edges are bidirectional.  Graph is undirected.");
	} else {
		writeln("Some graph edges are unidirectional");
	}

	printTimeCostTable();

	eliminateZeroRateValves();

	fo.writeln("\n");
	printTimeCostTable();

	fo.writeln("\n");
	printTimeCostTable2();

	fo.write("\nFlow Valves: ");
	foreach(key;flowVlvs.keys.sort) if(flowVlvs[key]) fo.writef("%3s",key);
	fo.write("\nZero Valves: ");
	foreach(key;zeroVlvs.keys.sort) if(zeroVlvs[key]) fo.writef("%3s",key);
	fo.writeln();

	fo.writeln("timeCost table is symetrical: ",isSymetrical);

	shortestPathBetweenEachPairOfNodes();

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
	vlvNum = 0;
	foreach(vlvTxt;matchAll(s1,ctr)) {
		vlvNum++;
		vlvTextToUbyteLookup[vlvTxt[1]] = vlvNum;
		vlvUbyteToTextLookup[vlvNum] = vlvTxt[1];
	}

	auto ctr0 = ctRegex!(`; tunnels* leads* to valves*`);
	auto ctr1 = ctRegex!(`([A-Z]{2}).*=(\d+)`);
	auto ctr2 = ctRegex!(`([A-Z]{2})`);
	vlvNum = 0;
	while(!f.eof()) {

		// s2[0] contains the valve id and rate
		// s2[1] contains the list of next valves
		auto s2 = f.readln.strip.split(ctr0);

		auto m0 = matchAll(s2[0],ctr1);
		auto id = m0.front[1];
		ubyte vlvRate = to!ubyte(m0.front[2]);
		vlvNum++; // start vlvNum with 1
		vlvToRate[vlvNum] = vlvRate;
		
		// fill table
		foreach(m1;matchAll(s2[1],ctr2)) {
			timeCost[vlvNum][vlvTextToUbyteLookup[m1.front]] = 1;
		}

		if(vlvRate > 0) {
			flowVlvs[vlvNum] = 1;
		} else {
			zeroVlvs[vlvNum] = 1;
		}
	}
}

void fillTableWith99() {
	for(ulong fromVlv = 1; fromVlv <= vlvNum; fromVlv++) {
		for(ulong toVlv = 1; toVlv <= vlvNum; toVlv++) {
			if(timeCost[fromVlv][toVlv] == 0) {
				timeCost[fromVlv][toVlv] = 99;
			}
		}
	}
}

bool allGraphEdgesBidirectional() {
	for(ulong fromVlv = 1; fromVlv <= vlvNum; fromVlv++) {
		for(ulong toVlv = 1; toVlv <= vlvNum; toVlv++) {
			if(timeCost[fromVlv][toVlv] != timeCost[toVlv][fromVlv]) return false;
		}
	}
	return true;
}

void printTimeCostTable() {
	string header = "   ";
	foreach(num;iota(1,vlvNum+1,1)) {
		header ~= format("%3s",num);
	}
	fo.writeln(header);
	fo.writeln(repeat('-',vlvNum*3 + 3));
	for(ubyte fromVlv=1; fromVlv <= vlvNum; fromVlv++) {
		fo.writef("%2s>",fromVlv);
		for(ubyte toVlv=1; toVlv <= vlvNum; toVlv++) {
			fo.writef("%3s",timeCost[fromVlv][toVlv]);
		}
		fo.writefln(" <%2s",fromVlv);
		if((fromVlv%10 == 0) && (fromVlv != vlvNum)) {
			fo.writeln(repeat('-',vlvNum*3 + 3));
		}
	}
	fo.writeln(repeat('-',vlvNum*3 + 3));
	fo.writeln(header);
}

void printTimeCostTable2() {
	string header = "   ";
	foreach(num;iota(1,vlvNum+1,1)) {
		if((cast(ubyte) num !in zeroVlvs) || (num == 1))
		header ~= format("%3s",num);
	}
	fo.writeln(header);
	fo.writeln(repeat('-',((flowVlvs.length+1)*3)+7));
	for(ubyte fromVlv=1; fromVlv <= vlvNum; fromVlv++) {
		if((fromVlv in zeroVlvs) && (fromVlv != 1)) continue;
		fo.writef("%2s>",fromVlv);
		for(ubyte toVlv=1; toVlv <= vlvNum; toVlv++) {
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

		for(ubyte tableRow = 1; tableRow <= vlvNum; tableRow++) {
			if(tableRow == zeroVlv) continue;

			// if no ref to this zero valve in this row go for another row
			if(timeCost[tableRow][zeroVlv] == 0) continue;

			fo.writeln(zeroVlv," tr=",tableRow," tC[",tableRow,"][",zeroVlv,"]=",timeCost[tableRow][zeroVlv]);
			for(ubyte toVlv = 1; toVlv <= vlvNum; toVlv++) {
				if(tableRow == toVlv) continue;
				if(timeCost[zeroVlv][toVlv] == 0) continue;
				if((timeCost[tableRow][toVlv] > timeCost[tableRow][zeroVlv] + timeCost[zeroVlv][toVlv]) ||
					(timeCost[tableRow][toVlv] == 0)) {
					timeCost[tableRow][toVlv] = to!ubyte(timeCost[tableRow][zeroVlv] + timeCost[zeroVlv][toVlv]);
				}
			}
			timeCost[tableRow][zeroVlv] = 0;
		}
		for(ubyte toVlv = 1; toVlv <= vlvNum; toVlv++) timeCost[zeroVlv][toVlv] = 0;
		//if(zeroVlv == 6) break;
	}
}

bool isSymetrical() {
	bool result = false;
	for(ubyte row =1; row <= vlvNum; row++) {
		for(ubyte col =1; col <= vlvNum; col++) {
			if(timeCost[row][col] != timeCost[col][row]) return result;
		}
	}
	result = true;
	return result;
}

void shortestPathBetweenEachPairOfNodes() {

	struct Valve {ubyte num; ubyte dist;}
	Valve[] valves;
	bool[60][60] visited;
	
	auto flowVplus1 = flowVlvs.dup;
	flowVplus1[1] = 1;
	fo.writeln(flowVplus1.keys.sort);

	foreach(srcVlv;flowVplus1.keys.sort) {
		valves ~= Valve(srcVlv, 0);
		foreach(ref v;flowVplus1) v = 0;

		while(valves.length > 0) {
			foreach(toVlv;flowVplus1.keys.sort) {
				if(toVlv == srcVlv) continue;
				if(timeCost[valves[0].num][toVlv] == 99) continue;
				if(timeCost[valves[0].num][toVlv] + vlvs[0].dist < 
					timeCost[srcVlv][toVlv]) {
					timeCost[srcVlv][toVlv] = timeCost[vlvs[0].num][toVlv] + vlvs[0].dist;

					// if valve not visited, add to queue
					if(flowVplus1[toVlv] == 0) {
						valves ~= Valve(toVlv,timeCost[srcVlv][toVlv]);
					}
				}
			}
			flowVplus1[toVlv] = 1;
		}
	}
}
//	1. start with node 1 and find the shortest path to each other node
//	then iterate through the remaining nodes.
//		2. using node number and DISTANCE to this node add nodes to visit
//		to the queue (queue will have current distance and node number);
// 		update the timeCost table with this nodes DISTANCE and mark node
// 		visited;
// 		3. if there are more nodes on the queue, pull one off.