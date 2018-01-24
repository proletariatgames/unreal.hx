package uhx;

@:enum abstract EStructFlags(Int) from Int {
  var UHXS_Templated = 1;
  var UHXS_POD = 2;
  var UHXS_CUSTOM = 3;
  // var UHXS_SharedPointer = 4;

  @:extern inline private function t():Int {
    return this;
  }

  @:extern inline public function hasAny(flags:EStructFlags):Bool {
    return this & flags.t() != 0;
  }

  @:extern inline public function hasAll(flags:EStructFlags):Bool {
    return this & flags.t() == flags.t();
  }

  @:op(A|B) inline public function add(flags:EStructFlags):EStructFlags {
    return this | flags.t();
  }
}
