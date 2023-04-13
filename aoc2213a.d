module aoc2213a;

import std.stdio;
import std.string;
import std.format;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;


File f;
File fo;

void main(string[] args) {
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;


	// f = File("temp.data");
	f = File("aoc2213a.data");
	fo = File("tempout.data","w");
	size_t RightOrderCount;
	DataSet[] ListSets = readListData(f);

	foreach(size_t i, ref ls; ListSets) {
		fo.writeln(ls.l); fo.writeln(ls.r);
		int result = listCheck(ls); fo.writeln(result,"\n");
		if(result == 1) {
			RightOrderCount += i+1;
		}
	}
	fo.writeln(RightOrderCount);


auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}

	struct DataSet {string l; string r;	}

	DataSet[] readListData(File f) {
		DataSet[] ListSets;
		while(true) {
			string line1 = f.readln.strip;
			string line2 = f.readln.strip;
			ListSets ~= DataSet(line1, line2);

			if(f.eof()) break;
			string blankline = f.readln;
		}
		return ListSets;
	}

	int listCheck(ref DataSet ls) {
		// right order; 1 = right, 0 = wrong, -1 = keep checking
		int ro = -1;
		int lx, rx;
		
		// [[ [] [d [, ][ ]] ]d ], d[ d] dd d, ,[ ,] ,d ,,
		while(true) {
			string lstr = to!string(ls.l[lx]);
			lstr = isNumeric(lstr) ? "d" : lstr;
			string rstr = to!string(ls.r[rx]);
			rstr = isNumeric(rstr) ? "d" : rstr;
			string s = lstr ~ rstr;

			if(ls.l[lx] == ls.r[rx]) {
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
				if(isNumeric(to!string(ls.r[rx+1])))
					// if string is ex. 10 be sure to wrap both digits i.e. [10]
					ls.r = ls.r[0..rx] ~ "[" ~ ls.r[rx..rx+2] ~ "]" ~ ls.r[rx+2..$];
				else
					ls.r = ls.r[0..rx] ~ "[" ~ ls.r[rx] ~ "]" ~ ls.r[rx+1..$];
			} else if(s == "d[") {
				if(isNumeric(to!string(ls.l[lx+1])))
					// if string is ex. 10 be sure to wrap both digits i.e. [10]
					ls.l = ls.l[0..lx] ~ "[" ~ ls.l[lx..lx+2] ~ "]" ~ ls.l[lx+2..$];
				else
					ls.l = ls.l[0..lx] ~ "[" ~ ls.l[lx] ~ "]" ~ ls.l[lx+1..$];
			} else if(s == "[," || s == ",[" || s == "d," || s == ",d") {
				fo.writeln("[,  ,[  d,  ,d");
				ro = -1; break;
			} else if(s == "dd") {
				// right-hand string
				int rval;
				if(isNumeric(to!string(ls.r[rx+1]))) // if double digit
					rval = to!int(ls.r[rx..rx+2]);
				else // else single digit
					rval = to!int(to!string(ls.r[rx]));

				// left-hand string
				int lval;
				if(isNumeric(to!string(ls.l[lx+1]))) // if double digit
					lval = to!int(ls.l[lx..lx+2]);
				else // else single digit
					lval = to!int(to!string(ls.l[lx]));

				ro = lval < rval ? 1 : 0; break;
				
			} else {fo.writeln("else ",ls.l[lx]," ",ls.r[rx]);
				ro = -1; break;
			}

			if (lx +1 >= ls.l.length) {
				fo.writeln("left string ended");
				ro = 1; break;
			} else {lx++;}

			if (rx +1 >= ls.r.length) {
				fo.writeln("right string ended");
				ro = 0; break;
			} else {rx++;}
		}
		fo.writeln(lx," ",ls.l[0..lx+1]);
		fo.writeln(rx," ",ls.r[0..rx+1]);
		return ro;
	}