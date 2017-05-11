package uhx.compiletime.tools;

class Timer {
  public var elapsed(default,null):Float;
  private var last:Float;

  public inline function new() {
    elapsed = 0;
    this.start();
  }

  inline public function start() {
    this.last = Sys.time();
  }

  inline public function stop() {
    this.elapsed += Sys.time() - this.last;
    this.last = 0;
  }

  public inline function toString() {
    if (elapsed < 60) {
      return elapsed + 's';
    } else {
      return Std.int(elapsed / 60) + ":" + elapsed % 60;
    }
  }

}
