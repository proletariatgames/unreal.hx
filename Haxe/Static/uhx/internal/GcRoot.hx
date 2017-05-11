package uhx.internal;

class GcRoot {
  private static var root(default, null):GcRoot = new GcRoot(null,null);

  private var last:GcRoot;
  private var next:GcRoot;
  public var value:Dynamic;

  private function new(value:Dynamic, next:GcRoot) {
    this.value = value;
    this.next = next;
    if (next == null) {
#if (debug || assertations)
      if (root != null)
        throw 'GcRoot assert: root is not null';
#end
      this.last = this;
      this.next = this;
    } else {
      this.last = next.last;
      this.last.next = this;
      next.last = this;
    }
  }

  public static function create(value:Dynamic):GcRoot {
#if (debug || assertations)
    if (root == null) throw 'GcRoot assert: root is null';
#end
    return new GcRoot(value,root);
  }

  @:void @:nonVirtual public function destruct() {
    this.last.next = this.next;
    this.next.last = this.last;
    this.next = this.last = null;
    this.value = null;
  }
}

