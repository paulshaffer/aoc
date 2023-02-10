module aoc2206b;

import std.stdio;
import core.time: MonoTime;


void main(){
//++++++++++++++++++++++++++++++++++++++++++++
auto file = File("aoc2206a.data","r");
//auto file = File("temp.data","r");
auto ds = file.readln;
enum mark = 4;
int i;
int j = 1;
int lower;

auto progStartTime = MonoTime.currTime;

for( ; j < ds.length; j++) {
	for(i = j - 1; i >= lower; i--) {
		//writeln("           ",ds);
		//writeln("[i..j]=",ds[i..j+1]);
		//writeln("           ",ds[lower]," ",ds[i]," ",ds[j]);
		//writefln("          %2s%2s%2s\n",lower,i,j);
		if (ds[i] == ds[j]) {
			lower = i + 1; break; // next j
		}
	}
	//writeln(j," ",i," ",j-i);
	if ((j-i) == mark) {break;}
}
auto progEndTime = MonoTime.currTime;

//writeln(lower," ",i," ",j);
writeln(j+1," ",ds[lower..j+1]);
writeln(progEndTime - progStartTime);
//++++++++++++++++++++++++++++++++++++++++++++


//++++++++++++++++++++++++++++++++++++++++++++

lower = j + 1; // start after the 4 char mark
j += 2; //

auto progStartTime2 = MonoTime.currTime;

for( ; j < ds.length; ++j) {
	for(i = j - 1; i >= lower; --i) {
		//writeln("           ",ds);
		//writeln("[i..j]=",ds[i..j+1]);
		//writeln("           ",ds[lower]," ",ds[i]," ",ds[j]);
		//writefln("          %2s%2s%2s\n",lower,i,j);
		if (ds[i] == ds[j]) {
			lower = i + 1; break; // next j
		}
	}
	enum msgMarkLen = 14;
	//writeln(j," ",i," ",j-i);
	if ((j-i) == msgMarkLen) {break;}
}
auto progEndTime2 = MonoTime.currTime;

writeln(j+1," ",ds[lower..j+1]);
writeln(progEndTime2 - progStartTime2);
//++++++++++++++++++++++++++++++++++++++++++++
}