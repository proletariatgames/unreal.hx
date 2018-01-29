package unreal;

#if macro
import haxe.macro.Expr;

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

  /** Safe version of iteration that promptly disposes the iterator.
      @param tParam The type of actor to iterate.
      @param world The world to look in.
      @param fn The function to call for each item, with signature $tParam->Bool. Return false to break.
   **/
  macro public static function iterate<T>(tParam:ExprOf<unreal.TypeParam<T>>, world:Expr, fn:ExprOf<T->Bool>) : Expr {
    return macro {
      var it = unreal.TActorIteratorImpl.create($tParam, $world);
      var fn = $fn;
      try {
        while (!it.op_Not()) {
          if (!fn(it.op_Dereference())) {
            break;
          }
          it.op_Increment();
        }
      } catch (e:Dynamic) {
        it.dispose();
        throw e;
      }

      it.dispose();
    };
  }

  /** Safe version of iteration that promptly disposes the iterator.
      @param tParam The type of actor to iterate.
      @param world The world to look in.
      @param class The subclass (UClass) to filter by.
      @param fn The function to call for each item, with signature $tParam->Bool. Return false to break.
   **/
  macro public static function iterateForSubclass<T>(tParam:ExprOf<unreal.TypeParam<T>>, world:Expr, cls:Expr, fn:ExprOf<T->Bool>) : Expr {
    return macro {
      var it = unreal.TActorIteratorImpl.createForSubclass($tParam, $world, $cls);
      var fn = $fn;
      try {
        while (!it.op_Not()) {
          if (!fn(it.op_Dereference())) {
            break;
          }
          it.op_Increment();
        }
      } catch (e:Dynamic) {
        it.dispose();
        throw e;
      }

      it.dispose();
    };
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
