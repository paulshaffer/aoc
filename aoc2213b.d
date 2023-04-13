module aoc2213b;

import std.stdio;
import std.string;
import std.format;
import std.array;
import std.algorithm;
import std.conv: to;
import core.time: MonoTime;

File f;
File fo;

enum markerString1 = "[[2]]";
enum markerString2 = "[[6]]";

void main(string[] args) {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;

	// f = File("temp.data");
	f = File("aoc2213a.data");
	fo = File("tempout2.data","w");
	string[] ListSets = readListData(f);
	sortSets(ListSets);
	size_t i1 = searchFor(markerString1,ListSets);
	size_t i2 = searchFor(markerString2,ListSets);
	size_t adventOfCodeKeyValue13b = i1 * i2;
	writeln(i1," ",i2," ",adventOfCodeKeyValue13b);

	// write to file for diagnostic value
	// foreach (size_t i, l;ListSets) {
	// 	fo.writeln(i+1," ",l);
	// }

auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}

	string[] readListData(File f) {
		string[] ListSets; //
		while(!f.eof()) {
			string set = f.readln.strip;
			if(set == "") continue;
			set = set.replace("10",":");
			ListSets ~= set;
		}
		ListSets ~= markerString1;
		ListSets ~= markerString2;
		return ListSets;
	}

	bool isVal(const char s) {
		return (s>=0x30 && s<=0x3A) ? true : false;
	}

	void sortSets(ref string[] ls) {
		size_t sortloopCount = 0, swaps = 0, swapCount = 0;
		bool sorted = false;
		while(!sorted) {
			for(size_t i = 1; i < ls.length; i=i+1) { 
				string l = ls[i-1]; 
				string r = ls[i]; 
				size_t lx = 0, rx = 0, ro = -1;
				while(true) {
					string lstr = isVal(l[lx]) ? "d" : to!string(l[lx]);
					string rstr = isVal(r[rx]) ? "d" : to!string(r[rx]);
					string s = lstr ~ rstr;

					if(l[lx] == r[rx]) {
					} else if(s == "][") {
						ro = 1; break;
					} else if(s == "[]") {
						ro = 0; break;
					} else if(s == "]d") {
						ro = 1; break;
					} else if(s == "d]") {
						ro = 0; break;
					} else if(s == "],") {
						ro = 1; break;
					} else if(s == ",]") {
						ro = 0; break;
					} else if(s == "[d") {
						r = r[0..rx] ~ "[" ~ r[rx] ~ "]" ~ r[rx+1..$];
					} else if(s == "d[") {
						l = l[0..lx] ~ "[" ~ l[lx] ~ "]" ~ l[lx+1..$];
					} else if(s == "[," || s == ",[" || s == "d," || s == ",d") {
						fo.writeln("[,  ,[  d,  ,d");
						fo.write(l,"\n",l[0..lx+1],"  ",lx,"\n");
						fo.write(r,"\n",r[0..rx+1],"  ",rx,"\n");
						ro = -1; break;
					} else if(s == "dd") {
						ro = l[lx] < r[rx] ? 1 : 0; break;				
					} else {fo.writeln("else ",l[lx]," ",r[rx]);
						ro = -1; break;
					}

					if (lx +1 >= l.length) {
						fo.writeln("left string ended");
						ro = 1; break;
					} else {lx++;}

					if (rx +1 >= r.length) {
						fo.writeln("right string ended");
						ro = 0; break;
					} else {rx++;}
				} // while true
				if (ro == 0) {
					swaps++;
					ls[i]   = l;
					ls[i-1] = r;
				}
			} // for
			if(swaps == 0) sorted = true;
			swapCount += swaps; swaps = 0; sortloopCount++;
		} // while !sorted
	}

	size_t searchFor(string s, ref string[] ls) {
		foreach(size_t i, l; ls) {
			auto rs = findSplit(l,s);
			if(rs[1] == s) { // s found in l
				bool preStringOk = true; 
				foreach(c;rs[0]) { // look for only [
					if(c != '[') {
						preStringOk = false; break;
					}
				}
				bool postStringOk = true;
				foreach(c;rs[2]) { // look for only ]
					if(c != ']') {
						postStringOk = false; break;
					}
				}
				if(preStringOk && postStringOk) {
					return i+1; // row/index in ls array
				}
			}
		}
		return 0;
	}