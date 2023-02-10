
import std.stdio;
import std.string: strip;
import std.array: split;
import std.conv: to;
import core.time: MonoTime;
import std.format;

void main(){
	int[string] aa;
	writeln(typeof(aa).stringof);
	int a=5, b=4;
	aa["34554"] = 56;
	aa.writeln;
	aa["34554"].writeln;
	aa["sdfsf"]++;
	aa.writeln;


}

