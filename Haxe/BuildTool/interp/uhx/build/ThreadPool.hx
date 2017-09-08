package uhx.build;
import cpp.vm.Thread;
import cpp.vm.Deque;

class ThreadPool {
  public var size(default, null):Int;
  private var deque:Deque<Void->Void> = new Deque();
  private var threads:Array<Thread>;

  public function new(size) {
    this.size = size;
    this.threads = [for (i in 0...size) Thread.create(loop)];
  }

  private function loop() {
    while(true) {
      var cur = deque.pop(true);
      if (cur == null) {
        deque.push(null);
        return;
      }
      cur();
    }
  }

  public function close() {
    deque.push(null);
  }

  public function spawn(fn:Void->Void) {
    deque.add(fn);
  }

  public function runCollection(fns:Array<Void->Bool>):Void->Bool {
    var ret = new Deque();
    var finished = false;
    for (fn in fns) {
      deque.add(function() {
        if (finished) {
          ret.add(true);
        }

        var res = fn();
        if (res) {
          ret.add(true);
        } else {
          ret.push(false);
        }
      });
    }

    return function() {
      var result = true;
      for (fn in fns) {
        if(!ret.pop(true)) {
          finished = true;
          return false;
        }
      }
      return true;
    }
  }

  public function partitionData<T>(arr:Array<T>, minLengthEach:Int, exec:Int->Array<T>->Bool):{ n:Int, getResult:Void->Bool } {
    var lenEach = Std.int(arr.length / this.size);
    if (lenEach < minLengthEach) {
      lenEach = minLengthEach;
    }

    var n = 0;
    var fns = [];
    while(arr.length > 0) {
      var start = arr.length - lenEach;
      if (start < 0) {
        start = 0;
      }
      var cur = arr.splice(start, arr.length-start);
      fns.push(exec.bind(n,cur));
      n++;
    }
    return { n:n, getResult:runCollection(fns) };
  }
}