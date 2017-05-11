package uhx.compiletime.tools;

@:forward abstract HelperBuf(StringBuf) from StringBuf to StringBuf {
  inline public function new() {
    this = new StringBuf();
  }

  @:op(A<<B) inline public function add(dyn:Dynamic):HelperBuf {
    this.add(dyn);
    return this;
  }

  @:extern inline public function mapJoin<T>(arr:Iterable<T>, fn:T->String) {
    var first = true;
    for (val in arr) {
      if (first) first = false; else this.add(', ');
      this.add(fn(val));
    }
  }
}

