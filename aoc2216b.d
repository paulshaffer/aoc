module aoc2216b;

import std.stdio;
import std.file;
import std.conv: to;
import std.string;
import std.algorithm;
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
ubyte[ubyte] flowVandAA;
ubyte[ubyte] myArr;
ubyte[ubyte] elephantArr;
ubyte[] arr, saveArr;
int totalflow, bestflow, partBtotal;
// ubyte[ubyte] sourceVlvs;

ubyte firstVlv;
ubyte vlvNum;
ubyte[60][60] timeCost, tc2;
enum totalTime = 26;

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
		fo.writeln("All edges are bidirectional.  Graph is undirected.");
	} else {
		fo.writeln("Some graph edges are unidirectional");
	}

	printTimeCostTable();

	eliminateZeroRateValves();

	fo.writeln("\n");
	printTimeCostTable();

	fo.writeln("\n");
	printTimeCostTable2(timeCost);

	fo.write("\nFlow Valves: ");
	foreach(key;flowVlvs.keys.sort) if(flowVlvs[key]) fo.writef("%3s",key);
	fo.write("\nZero Valves: ");
	foreach(key;zeroVlvs.keys.sort) if(zeroVlvs[key]) fo.writef("%3s",key);
	fo.writeln();

	// fo.writeln("timeCost table is symetrical: ",isSymetrical(timeCost));

	shortestPathBetweenEachPairOfNodes();
	
	// fo.writeln("\n");
	printTimeCostTable2(timeCost);
	printTimeCostTable2(tc2);

	add1ToTable();
	printTimeCostTable2(tc2);
	fo.writeln("tc table is symetrical: ",isSymetrical(tc2));

	auto algoStartTime = MonoTime.currTime;

	arr = flowVlvs.keys;
	arr.sort;
	fo.writeln(arr);
	findBestPath();
	partBtotal = bestflow;

	fo.writeln(myArr);
	foreach(k,v;flowVlvs) {
		if(k in myArr) {
			continue;
		} else {
			elephantArr[k] = 0;
			fo.write(k," ");
		}
	}
	fo.writeln();
	fo.writeln(elephantArr);

	arr.length = 0;
	arr = elephantArr.keys;
	arr.sort;
	fo.writeln(arr);
	findBestPath();
	partBtotal += bestflow;
	fo.writeln(partBtotal);

	auto algoEndTime = MonoTime.currTime;

//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(algoEndTime - algoStartTime);
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
		if(vlvTxt[1] == "AA") firstVlv = vlvNum;
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
			if((timeCost[fromVlv][toVlv] == 0) && (fromVlv != toVlv)){
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

void printTimeCostTable2(ubyte[60][60] tc) {
	string header = "   ";
	foreach(num;iota(1,vlvNum+1,1)) {
		if((cast(ubyte) num !in zeroVlvs) || (num == firstVlv))
		header ~= format("%3s",num);
	}
	fo.writeln(header);
	fo.writeln(repeat('-',((flowVlvs.length+1)*3)+7));
	for(ubyte fromVlv=1; fromVlv <= vlvNum; fromVlv++) {
		if((fromVlv in zeroVlvs) && (fromVlv != firstVlv)) continue;
		fo.writef("%2s>",fromVlv);
		for(ubyte toVlv=1; toVlv <= vlvNum; toVlv++) {
			if((toVlv in zeroVlvs) && (toVlv != firstVlv)) continue;
			fo.writef("%3s",tc[fromVlv][toVlv]);
		}
		fo.writefln(" <%2s",fromVlv);
	}
	fo.writeln(repeat('-',((flowVlvs.length+1)*3)+7));
	fo.writeln(header);
}

void eliminateZeroRateValves() {
	// find a zero rate valve
	foreach(ubyte zeroVlv; zeroVlvs.keys.sort) {
		if(zeroVlv == firstVlv) continue;

		for(ubyte tableRow = 1; tableRow <= vlvNum; tableRow++) {
			if(tableRow == zeroVlv) continue;

			// if no ref to this zero valve in this row go for another row
			if(timeCost[tableRow][zeroVlv] == 0) continue;

			// fo.writeln(zeroVlv," tr=",tableRow," tC[",tableRow,"][",zeroVlv,"]=",timeCost[tableRow][zeroVlv]);
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

bool isSymetrical(ubyte[60][60] tc) {
	bool result = true;
	for(ubyte row =1; row <= vlvNum; row++) {
		for(ubyte col =1; col <= vlvNum; col++) {
			if(tc[row][col] != tc[col][row]) {
				fo.writeln("row ",row,"  col ",col,"   rcDist ",tc[row][col]);
				result = false;
			}
		}
	}
	return result;
}

void shortestPathBetweenEachPairOfNodes() {
	tc2 = timeCost;
	ubyte[ubyte] valves;
	ubyte currVlv;
	
	flowVandAA = flowVlvs.dup;
	flowVandAA[firstVlv] = 1;

	foreach(sourceVlv;flowVandAA.keys.sort) {
		valves.clear;
		valves[sourceVlv] = 0;
		currVlv = sourceVlv;

		foreach(ref val;flowVandAA) val = 0;
		flowVandAA[sourceVlv] = 1;
		
		while(valves.length > 0) {
			// fo.writeln(valves);
			// fo.write(currVlv);
			foreach(toVlv;flowVandAA.keys.sort) {
				if(toVlv == currVlv) continue;
				if(timeCost[currVlv][toVlv] == 99) continue;
				// fo.write(" ",toVlv);
				if(tc2[sourceVlv][currVlv] + timeCost[currVlv][toVlv] < 
					tc2[sourceVlv][toVlv]) {
					tc2[sourceVlv][toVlv] = to!ubyte(tc2[sourceVlv][currVlv]
					                              + timeCost[currVlv][toVlv]);
				}
				// if valve not visited, add to queue
				if(flowVandAA[toVlv] == 0) {
					valves[toVlv] = 0;
					flowVandAA[toVlv] = 1;
				}
			}
			// fo.writeln();
			valves.remove(currVlv);

			ubyte time = 255;
			currVlv = 0;
			foreach(v;valves.keys) {
				if((v != sourceVlv) && (tc2[sourceVlv][v] < time)) {
					time = tc2[sourceVlv][v];
					currVlv = v;
				}
			}
		}
	}
}

void add1ToTable() {
	foreach(fromVlv;flowVandAA.keys.sort) {
		foreach(toVlv;flowVandAA.keys.sort) {
			if(fromVlv==toVlv) continue;
			tc2[fromVlv][toVlv]++;
		}
	}
}

ulong fact(ulong n){
	return n>=2 ? (n) * fact(n-1) : 1;
}

void findBestPath() {
	bestflow = 0;
	size_t loopcnt, breakcnt;
	do {
		int rate = 0;
		ubyte fromVlv = firstVlv, timecost = 0;
		int timeleft = totalTime;
		totalflow = 0;
		foreach(size_t i, toVlv; arr) {
			rate = vlvToRate[toVlv];
			timecost = tc2[fromVlv][toVlv];

			if(timeleft - timecost < 1) {
				arr[i+1..$].sort!("a > b");
				breakcnt++;
				break;
			} else {
				timeleft -= timecost;
				totalflow += timeleft * rate;
				fromVlv = toVlv;
			}
		}

		if(totalflow >= bestflow) {
			bestflow = totalflow;
			saveArr = arr.dup;
		}

		loopcnt++;
	} while(nextPermutation(arr));

	fo.writeln("loops ",loopcnt,"   breaks ",breakcnt);
	fo.writefln("total possible perms %,3s",fact(to!ulong(flowVlvs.length)));
	fo.writefln("perms avoided        %,3s",fact(to!ulong(flowVlvs.length)) - breakcnt);
	fo.writeln("best flow ",bestflow);
	fo.writeln(saveArr); writeln(saveArr);

	ubyte pv = firstVlv;
	int tl = totalTime;
	totalflow = 0;
	fo.writeln("NN TX TC RT*TL= FL");
	foreach(v;saveArr) {
		tl -= tc2[pv][v];
		if(tl < 0) break;
		fo.writefln("%2s %2s %2s %2s*%2s=%3s",
			v,vlvUbyteToTextLookup[v],tc2[pv][v],vlvToRate[v],
			tl, tl*vlvToRate[v]);
			totalflow += tl*vlvToRate[v];
			pv = v;
			myArr[v] = 0;
	}
	fo.writefln("              %4s",totalflow);
}