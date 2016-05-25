package unreal;
#if !macro
#else
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.Tools;
#end

abstract POwnedPtr<T>(PPtr<T>) from T {

  macro public function toSharedPtr(ethis:haxe.macro.Expr):haxe.macro.Expr.ExprOf<TSharedPtr<T>> {
    return macro unreal.TSharedPtr.MakeShareable(${getTypeParam(ethis)}, cast $ethis);
  }

  macro public function toSharedRef(ethis:haxe.macro.Expr):haxe.macro.Expr.ExprOf<TSharedRef<T>> {
    return macro unreal.TSharedRef.MakeShareable(${getTypeParam(ethis)}, cast $ethis);
  }

  macro public function toSharedPtrTS(ethis:haxe.macro.Expr):haxe.macro.Expr.ExprOf<TThreadSafeSharedPtr<T>> {
    return macro unreal.TThreadSafeSharedPtr.MakeShareable(${getTypeParam(ethis)}, cast $ethis);
  }

  macro public function toSharedRefTS(ethis:haxe.macro.Expr):haxe.macro.Expr.ExprOf<TThreadSafeSharedRef<T>> {
    return macro unreal.TThreadSafeSharedRef.MakeShareable(${getTypeParam(ethis)}, cast $ethis);
  }

#if !macro

  /**
    Gets the underlying pointer. Please be aware that if no shared pointer or reference is created,
    this object _will leak memory_, as calling `unsafeGet` will not add any kind of finalizer to this object
   **/
  inline public function getRaw():PPtr<T> {
    return this;
  }

#else
  private static function getTypeParam(ethis:Expr):Expr {
    var type = getUnderlyingType(ethis).toComplexType();
    return macro new unreal.TypeParam<$type>();
  }
  private static function getUnderlyingType(ethis:Expr):Type {
    var ret = Context.typeof(ethis);
    while(true) {
      switch(Context.follow(ret)) {
      case TAbstract(a,tl) if(a.toString() == 'unreal.POwnedPtr'):
        return tl[0];
      case t:
        return t;
      }
    }
  }
#end
}
