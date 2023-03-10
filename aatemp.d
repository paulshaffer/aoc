
import std.stdio;

int isPrime(int n){
	  int i, count;

      for(i=1; i<=n; i++) {
        if (n % i == 0) {
          count = count + 1;
        }
      }

     if (count == 2) {
        return 1;
      } else {
        return 0;
      }
}
void main(){
writeln(isPrime(2));
writeln(isPrime(33));
writeln(isPrime(37));
writeln(isPrime(7879));
}

