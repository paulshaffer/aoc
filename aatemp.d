import std.stdio : writeln;
import std.algorithm : map;
import std.range : iota;
import std.parallelism : taskPool;
import core.time: MonoTime;

/* On Intel i7-3930X and gdc 9.3.0:
 * 5140ms using std.algorithm.reduce
 * 888ms using std.parallelism.taskPool.reduce
 *
 * On AMD Threadripper 2950X, and gdc 9.3.0:
 * 2864ms using std.algorithm.reduce
 * 95ms using std.parallelism.taskPool.reduce
 */
void main()

{
  auto progStartTime = MonoTime.currTime;

  auto nums = iota(1.0, 1_000_000_000.0);

  auto x = taskPool.reduce!"a + b"(
      0.0, map!"1.0 / (a * a)"(nums)
  );

  writeln("Sum: ", x);

  auto progEndTime = MonoTime.currTime;
writeln(progEndTime - progStartTime);
}