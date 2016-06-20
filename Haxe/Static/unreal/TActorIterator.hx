package unreal;

import haxe.macro.Expr;

#if macro
// avoid recursive build macros
typedef TActorIteratorImpl<T> = Dynamic;
#end

@:forward abstract TActorIterator<T>(TActorIteratorImpl<T>) from TActorIteratorImpl<T> to TActorIteratorImpl<T> {
  public inline function new(native:TActorIteratorImpl<T>) this = native;
  public inline function iterator() return new TActorIteratorWrapper<T>(this);

  macro public static function create(?tParam:Expr, world:Expr) : Expr {
    return macro unreal.TActorIteratorImpl.create($tParam, $world);
  }

  macro public static function createForSubclass(?tParam:Expr, world:Expr, cls:Expr) : Expr {
    return macro unreal.TActorIteratorImpl.createForSubclass($tParam, $world, $cls);
  }

  macro public static function createNew(?tParam:Expr, world:Expr) : Expr {
    return macro unreal.TActorIteratorImpl.createNew($tParam, $world);
  }
}

private class TActorIteratorWrapper<T> {
  var it:TActorIterator<T>;
  public inline function new(it:TActorIterator<T>) {
    this.it = it;
  }

  public inline function hasNext() return !this.it.op_Not();
  public inline function next() : T {
    var val = this.it.op_Dereference();
    this.it.op_Increment();
    return val;
  }
}
