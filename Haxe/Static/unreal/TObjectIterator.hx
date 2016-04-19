package unreal;

import haxe.macro.Expr;

#if macro
// avoid recursive build macros
typedef TObjectIteratorImpl<T> = Dynamic;
#end

@:forward abstract TObjectIterator<T>(TObjectIteratorImpl<T>) from TObjectIteratorImpl<T> to TObjectIteratorImpl<T> {
  public inline function new(native:TObjectIteratorImpl<T>) this = native;
  public inline function iterator() return new TObjectIteratorWrapper<T>(this);

  macro public static function create(?tParam:Expr) : Expr {
    return macro unreal.TObjectIteratorImpl.create($tParam);
  }

  macro public static function createStruct(?tParam:Expr) : Expr {
    return macro unreal.TObjectIteratorImpl.createStruct($tParam);
  }
}

private class TObjectIteratorWrapper<T> {
  var it:TObjectIterator<T>;
  public inline function new(it:TObjectIterator<T>) {
    this.it = it;
  }

  public inline function hasNext() return !this.it.op_Not();
  public inline function next() : T {
    var val = this.it.op_Dereference();
    this.it.op_Increment();
    return val;
  }
}
