package uhx.compiletime.tools;

class Lst<T> {
  public var next(default, null):Null<Lst<T>>;
  public var value(default, null):T;

  public function new(value, next) {
    this.next = next;
    this.value = value;
  }

  inline public function add(value:T):Lst<T> {
    return new Lst(value, this);
  }

  public function iterator():Iterator<T>
  {
    var cur = this;
    return {
      hasNext:function() return cur != null,
      next:function() {
        var ret = cur.value;
        cur = cur.next;
        return ret;
      }
    };
  }

  public function toString() {
    var tmp = [];
    var cur = this;
    while (cur != null) {
      tmp.push(cur.value);
      cur = cur.next;
    }
    return tmp.toString();
  }
}
