package ue4hx.internal;

@:forward abstract HelperBuf(StringBuf) from StringBuf to StringBuf {
  inline public function new() {
    this = new StringBuf();
  }

  @:op(A+B) inline public function add(dyn:Dynamic):HelperBuf {
    this.add(dyn);
    return this;
  }
}

