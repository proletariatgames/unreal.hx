package unreal;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
class UObject {} // trick to avoid triggering build macros
#else
import unreal.UObject;
import unreal.Wrapper;
#end

#if !macro
@:access(unreal.Wrapper)
@:access(unreal.UObject.wrapped)
#end
class CoreAPI {

  #if !macro
  public static function equals(a:Dynamic, b:Dynamic) : Bool {
    if ((a == null) && (b == null)) {
      return true;
    } else if (a == null || b == null) {
      return false;
    } else if (Std.is(a, Wrapper) && Std.is(b, Wrapper)) {
      var wrapperA:Wrapper = cast a;
      var wrapperB:Wrapper = cast b;
      if (wrapperA.wrapped.ptr.getPointer() == wrapperB.wrapped.ptr.getPointer())
        return true;
      if (Type.getClass(wrapperA) == Type.getClass(wrapperB))
        return wrapperA._equals(wrapperB);
      return false;
    } else if (Std.is(a, unreal.UObject) && Std.is(b, UObject)) {
      var uobjectA:UObject = cast a;
      var ubojectB:UObject = cast b;
      return uobjectA.wrapped == ubojectB.wrapped;
    }
    return a == b;
  }

  inline public static function copy<T : Wrapper>(type:T):PHaxeCreated<T> {
    return cast type._copy();
  }

  inline public static function copyStruct<T : Wrapper>(type:T):T {
    return cast type._copyStruct();
  }
  #end // !macro

  /**
   * For UObject types, returns the object casted to the input class, or null if the object is null or not of that type.
   * This is meant as a replacement for Cast<Type> in Unreal C++
   * Example:
   *  var actor:AActor = GetOwner();
   *  var pawn:APawn = actor.as(APawn);
   *  if (pawn != null) { ... }
   */
  public static macro function as<T>(obj:ExprOf<UObject>, cls:ExprOf<Class<T>>) : ExprOf<T> {
    var clsType = switch (cls.expr) {
    case EConst(CIdent(className)):
      Context.toComplexType(Context.getType(className));
    case _:
      throw new Error('Expected class', cls.pos);
    }

    return macro @:pos(Context.currentPos()) {
      var _o = $obj;
      var _c:$clsType = _o != null && _o.IsA($cls.StaticClass()) ? cast _o : null;
      _c;
    };
  }
}
