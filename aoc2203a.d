module aoc2203a;
import std.stdio;
import std.string;

void main(){
	int total, cnt;
	auto rucksacks = File("aoc2203a.data","r");
	//auto rucksacks = File("temp.data","r");

	while(!rucksacks.eof){
		auto rucksack = rucksacks.readln.strip;
		bool itemMatch = false;
		foreach(itemPocketA;rucksack[0..$/2]) {
			foreach(itemPocketB;rucksack[$/2..$]) {
				if(itemPocketA == itemPocketB){
					itemMatch = true; ++cnt;
					auto itemPriority = (cast(byte) itemPocketA) - 96; // small a = 97 (-96=1,,26)
					if (itemPriority < 0) itemPriority += (96 - 38); // A = 65 (-38 = 27..52)
					total += itemPriority;
					writeln(cnt," ",rucksack," ",itemPocketA," ",itemPriority," ",total);
					break;
				}
			}
			if(itemMatch) break;
		}
	}
}