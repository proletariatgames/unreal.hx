package unreal;

@:enum abstract WrapperFlags(Int) from Int {
  var NeedsDestructor = 0x100;
  var Disposed = 0x200;

  @:op(A|B) inline public function add(flags:WrapperFlags):WrapperFlags {
    return this | (flags.t() & 0xFFFFFF00);
  }

  @:op(A&B) inline public function maskWith(mask:WrapperFlags):WrapperFlags {
    return this & (mask.t() | 0xFF);
  }

  @:op(~A) inline public function not():WrapperFlags {
    return ~this;
  }

  inline private function t() {
    return this;
  }

  inline public function hasAll(flags:WrapperFlags):Bool {
    var flags = flags & 0xFFFFFF00;
    return this & flags.t() == flags.t();
  }

  inline public function hasAny(flags:WrapperFlags):Bool {
    var flags = flags & 0xFFFFFF00;
    return this & flags.t() != 0;
  }
}
