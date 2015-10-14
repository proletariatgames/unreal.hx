package unreal;

/**
  This type is automatically added by the ExternBaker whenever a call to a templated function or type is made.
  It is only here to allow templates whose types can't be inferred by Haxe to still be called.

  If calling a templated function that can have its parameters inferred from Haxe, you can safely skip it
 **/
abstract TypeParam<T>(Dynamic) to Dynamic {
  @:extern inline public function new() {
    this = null;
  }
}
