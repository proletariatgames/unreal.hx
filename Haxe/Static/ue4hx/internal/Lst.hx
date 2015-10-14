package ue4hx.internal;

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
}
