package ue4hx.internal;

abstract AnyTypeParam<T>(Dynamic) to Dynamic {
  @:extern inline public function new() {
    this = null;
  }
}
