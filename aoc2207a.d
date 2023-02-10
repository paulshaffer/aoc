module aoc2207a;


import std.stdio;
import std.string;
import std.array;
import std.conv: to;
import core.time: MonoTime;
import std.path;
import std.algorithm: sort;
import std.algorithm.searching: canFind, startsWith;

ulong idx, globalSum, globalCnt;
string[] fs; // file system
string[] fsSorted;

File cmdHistory;
File f;

void main(){
// Timed vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
auto progStartTime = MonoTime.currTime;
//auto path = "/root/d1/d2/d3/file.txt";
//writeln(path," > dirName > ",dirName(path)); // /root/d1/d2/d3
//writeln(path," > rootName > ",rootName(path)); // /
//writeln(path," > baseName .txt > ",baseName(path, ".txt")); // file
//writeln(path," > stripExtesion > ",stripExtension(path)); // /root/d1/d2/d3/file
//writeln(path," > pathSplitter > ",pathSplitter(path)); // ["/", "root", "d1", "d2", "d3", "file.txt"]
//writeln(path," > buildPath / , a1 > ",buildPath("/" , "a1")); // /a1

cmdHistory = File("aoc2207a.data");
         f = File("aoc2207atest.txt","w");

enum root = "\\"; // equal to string of \
string currPath = root; // set starting path to root
fs ~= currPath; // add root to file system array

int lineNum;

// create string[] of files and directories
while(!cmdHistory.eof) {
	++lineNum;
	auto lineText = cmdHistory.readln.strip;
	//f.writefln("%4s %30s  ",lineNum,lineText);
	if(lineText[0] == cast(immutable(char))"$") {

		// set current path
		if(lineText[2..4] == "cd") {
			//f.writefln("%s %30s  ",lineText,lineNum);

			// $ cd /
			if(lineText[5] == cast(immutable(char))"/") {
				currPath = "\\";

			// $ cd ..
			} else if(lineText[5..7] == "..") {
				currPath = pathChomp(currPath);

			// $ cd dir name
			} else {
				currPath = buildPath(currPath,lineText[5..$]);
			}

		// $ ls - throw 'ls' away as the rest is either a file or dir
		} else {

		}

	// dir or file name; i.e. not a command ($)
	// dir
	} else if(lineText[0..3] == "dir") {
		fs ~= buildPath(currPath,lineText[4..$]~"\\");

	// file
	} else {
		fs ~= buildPath(currPath,lineText);
	}
}

fs = fs.sort.array;
auto dirTotal = dirCalc();
foreach(line;fs) f.writeln(line);
writeln(globalCnt," ",globalSum);

// Timed ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
writeln(MonoTime.currTime - progStartTime);
}

string pathChomp(string path) {
	for(auto i = path.length - 1; i >= 0; --i) {
		if(path[i] == cast(immutable(char))"\\") {
			if(i == 0) {
				path = path[0..1];
			} else {
				path = path[0..i];
			}
			break;
		}
	}
	return path;
}

ulong dirCalc() {
	ulong thisSum;
	ulong thisIdx = idx;
	string thisDir = fs[idx];
	ulong firstDigit = thisDir.length;

	idx++;
	while(true) {
		if (idx >= fs.length) break;
		
		if (startsWith(fs[idx], thisDir)) {

			if (isNumeric(to!string(fs[idx][firstDigit]))) {
				thisSum += to!int(fs[idx].baseName.split[0]);
				idx++;

			} else { // 1st digit not numeric
			thisSum += dirCalc();
			}

		} else { // fs[idx] does not start with thisDir
			break;
		}
	}

	if(thisSum <= 100_000) {
		globalSum += thisSum;
		globalCnt++;
	}

	fs[thisIdx] ~= "="~to!string(thisSum);
	return thisSum;
}