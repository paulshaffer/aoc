module aoc2219a;

import std.algorithm;
import std.stdio;
import std.file;
import std.format;
import core.time: MonoTime;
import std.conv;
import std.string: strip;
import std.array: replace;

File f,fo;

enum bluePrintQty = 30;
BluePrint[bluePrintQty + 1] bps;
BluePrint bp;

// Timed main() vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
void main(string[] args) {
auto progStartTime = MonoTime.currTime;
//-----------------------------------------------------------------------------
	string filename = args.length > 1 ? args[1] : "aoc2219a.data";
	f = File(filename);
	fo = File("tempout.data","w");

	loadBluePrintData();
	// printBluePrints();
	auto bpNum = 1;
	ProductionRun pr = { bp:bpNum, t:1, nbo:1 };
	auto bp = bps[bpNum];
	string buildThisBotType;

	// 1. check resources; decide what to build
	if(       botBuildPossible("geode",   bp,pr)) {
		    buildThisBotType = "geode";
	} else if(botBuildPossible("obsidian",bp,pr)) {
		    buildThisBotType = "obsidian";
	} else if(botBuildPossible("clay",    bp,pr)) {
		    buildThisBotType = "clay";
	} else if(botBuildPossible("ore",     bp,pr)) {
		    buildThisBotType = "ore";
	}

	// 2. collect resources for this minute
	pr.qo += pr.nbo;
	pr.qc += pr.nbc;
	pr.qb += pr.nbb;
	pr.qg += pr.nbg;
	
	// add newly built bots to bot tallies


//-----------------------------------------------------------------------------
auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}
// Timed main() ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

struct BluePrint {
	int num;
	Cost bco, bcc, bcb, bcg;
	string toString() { // @suppress(dscanner.suspicious.object_const)
		auto s = format("blue print number %02s\n",num);
		s =  s ~ format("  ore     -bot cost: %02s\n",bco);
		s =  s ~ format("  clay    -bot cost: %02s\n",bcc);
		s =  s ~ format("  obsidian-bot cost: %02s\n",bcb);
		s =  s ~ format("  geode   -bot cost: %02s\n",bcg);
		return s;
	}
}
struct Cost {
	int o,c,b;
	string toString () { // @suppress(dscanner.suspicious.object_const)
		string s1 = o > 0 ? format("ore %02s",o) : "";
		string s2 = c > 0 ? format("clay %02s",c) : "";
		string s3 = b > 0 ? format("obsidian %02s",b) : "";
		s1 = ((s2 != "") || (s3 != "")) ? s1~", " : s1;
		return s1 ~ s2 ~ s3;
	}
}

void loadBluePrintData() {
	import std.regex: ctRegex, matchAll, split;

	auto ctr = ctRegex!(`(\d+)`);
	while(!f.eof()) {
		auto s = f.readln().strip;
		auto m = matchAll(s, `(\d+)`);
		int n = to!int(m.hit);
		bps[n].num = n;
		m.popFront; bps[n].bco.o = to!int(m.hit);
		m.popFront; bps[n].bcc.o = to!int(m.hit);
		m.popFront; bps[n].bcb.o = to!int(m.hit);
		m.popFront; bps[n].bcb.c = to!int(m.hit);
		m.popFront; bps[n].bcg.o = to!int(m.hit);
		m.popFront; bps[n].bcg.b = to!int(m.hit);
	}
}

void printBluePrints() {
	foreach(size_t n, bp;bps) fo.writeln(bp);
}

struct ProductionRun {
	int bp; // blue print used
	int t; // time
	int qo, qc, qb, qg;
	int nbo, nbc, nbb, nbg;
	string toString() { // @suppress(dscanner.suspicious.object_const)
		string s = "======== PRODUCTION RUN ========\n";
		s = s ~ format("Blueprint Used %02s   Time %02s mins\n",bp,t);
		s = s ~ "      ore cly obs geo\n";
		s = s ~ format(" qty: %02s  %02s  %02s  %02s\n",qo,qc,qb,qg);
		s = s ~ format("bots: %02s  %02s  %02s  %02s\n",nbo,nbc,nbb,nbg);
		return s;
	}
}

bool botBuildPossible(string botType, BluePrint bp, ProductionRun pr) {
	final switch (botType) {
    case "ore":
		return pr.qo >= bp.bco.o ? true : false;
    case "clay":
		return pr.qo >= bp.bcc.o ? true : false;
    case "obsidian":
		return (	(pr.qo >= bp.bcb.o) &&
					(pr.qc >= bp.bcb.c)		)? true : false;
    case "geode":
		return (	(pr.qo >= bp.bcg.o) &&
					(pr.qb >= bp.bcg.b)		)? true : false;
	}
}

void botBuild("geode",bp, ref pr) {

}