module aoc2206a2;

import std.stdio;
import std.string: strip;
import std.array: split;
import std.conv: to;
import std.algorithm.mutation: reverse;
import std.range: transposed;
import core.time: MonoTime;


void main(){
//++++++++++++++++++++++++++++++++++++++++++++
auto file = File("aoc2206a.data","r");
//auto file = File("temp.data","r");
auto d = file.readln;
enum mark = 4;
int markPos;

auto progStartTime = MonoTime.currTime;

for(int i=0; i <= (d.length - mark); ++i) {
	//auto sl = d[i .. (i + mark)];
	//write(i);

	if (d[i]!=d[i+1] && d[i]!=d[i+2] && d[i]!=d[i+3] && 
		d[i+1]!=d[i+2] && d[i+1]!=d[i+3] && d[i+2]!=d[i+3]) {
			
		markPos = i + mark;
		writeln(" ",markPos);
		break;
	}
}

auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
//++++++++++++++++++++++++++++++++++++++++++++


//++++++++++++++++++++++++++++++++++++++++++++
file.rewind;
auto ds = file.readln;

markPos = 0;
int i;
int j =  1;
int lower = markPos;

auto progStartTime2 = MonoTime.currTime;

for( ; j < ds.length; ++j) {
	for(i = j - 1; i >= lower; --i) {
		//writeln("           ",ds);
		//writeln("[lower..j]=",ds[lower..j+1]);
		//writeln("           ",ds[lower]," ",ds[i]," ",ds[j]);
		//writefln("          %2s%2s%2s\n",lower,i,j);
		if (ds[i] == ds[j]) {
			lower = i + 1; break; // next j
		}
	}
	//writeln(j," ",i," ",j-i);
	if ((j-i) == mark) {break;}

}
writeln(j+1);

auto progEndTime2 = MonoTime.currTime;
writeln(progEndTime2 - progStartTime2);
//++++++++++++++++++++++++++++++++++++++++++++
}