module aoc2203b;
import std.stdio;
import std.string;
import core.time: MonoTime;

int itemPriority (char elfItem){
	int itemPriority = (cast(byte) elfItem) - 96; // small a = 97 (-96=1..26)
	if (itemPriority < 0) itemPriority += (96 - 38); // A = 65 (-38 = 27..52)
	return itemPriority;
}

immutable(char) lookInOtherRuckSack(immutable(char) item, string rucksack){
	foreach(thing;rucksack){
		if (item == thing){
			return item;
		}
	}
	return ' ';
}

void main(){
	auto progStartTime = MonoTime.currTime;

	int total, cnt;
	auto rucksacks = File("aoc2203a.data","r");

	while(!rucksacks.eof){
		bool badgesFound = false;
		auto rucksack1 = rucksacks.readln.strip;
		auto rucksack2 = rucksacks.readln.strip;
		auto rucksack3 = rucksacks.readln.strip;
		foreach(item;rucksack1) {
			if (item == lookInOtherRuckSack(item, rucksack2)) {
				if (item == lookInOtherRuckSack(item, rucksack3)) {
					badgesFound = true; ++cnt;
					total += itemPriority(item);
					writeln(rucksack1); writeln(rucksack2); writeln(rucksack3);
					writeln (item," ", total, " ",cnt);
				}
			}

		if (badgesFound) break;
		}//foreach(item;rucksack1)
	}

	writeln(MonoTime.currTime - progStartTime);
}