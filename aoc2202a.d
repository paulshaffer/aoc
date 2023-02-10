module aoc2202a;
import std.stdio;
import std.string:strip;

void main() {
	size_t game, score;
	File f = File("aoc2202.data","r");

	while(!f.eof) {
		auto gameRound=f.readln.strip;
		final switch (gameRound) {
		case "A X": game = 0 + 3; break;
		case "A Y": game = 3 + 1; break;
		case "A Z": game = 6 + 2; break;
		case "B X": game = 0 + 1; break;
		case "B Y": game = 3 + 2; break;
		case "B Z": game = 6 + 3; break;
		case "C X": game = 0 + 2; break;
		case "C Y": game = 3 + 3; break;
		case "C Z": game = 6 + 1; break; }

		score += game;
		writefln("%s%2s%6s",gameRound,game,score);
	}
	
	writeln(score);
}
