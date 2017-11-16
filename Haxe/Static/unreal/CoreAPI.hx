package unreal;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;

class UObject {} // trick to avoid triggering build macros
#else
import unreal.UObject;
import unreal.Wrapper;

typedef AutoImportLogVerbosity = ELogVerbosity;
#end

#if !macro
@:access(unreal.Wrapper)
@:access(unreal.UObject.wrapped)
#end
class CoreAPI {

  @:noUsing macro public static function check(expr:ExprOf<Bool>):Expr {
    if (
        (Context.defined("debug") && !Context.defined("NO_ASSERTIONS")) ||
        Context.defined("WITH_ASSERTIONS")
      )
    {
      return macro if ($expr) {
        @:pos(expr.pos) trace("Fatal", "Assertion failed: " + $v{expr.toString()});
      }
    } else {
      return macro {};
    }
  }

  public static macro function getComponent<T>(obj:ExprOf<AActor>, cls:ExprOf<Class<T>>) : ExprOf<T> {
    var clsType = switch (cls.expr) {
    case EConst(CIdent(className)):
      Context.toComplexType(Context.getType(className));
    case _:
      throw new Error('Expected class', cls.pos);
    }

    return macro @:pos(Context.currentPos()) {
      var _o = $obj;
      var _c:$clsType = cast _o.GetComponentByClass($cls.StaticClass());
      _c;
    };
  }

  public static macro function addComponent<T>(obj:ExprOf<AActor>, cls:ExprOf<Class<T>>) : ExprOf<T> {
    var clsType = switch (cls.expr) {
    case EConst(CIdent(className)):
      Context.toComplexType(Context.getType(className));
    case _:
      throw new Error('Expected class', cls.pos);
    }

    return macro @:pos(Context.currentPos()) {
      var _o = $obj;
      var _c:$clsType = unreal.UObject.NewObjectByClass(new unreal.TypeParam<$clsType>(), _o, $cls.StaticClass());
      _c.RegisterComponent();
      _c;
    };
  }

  public static macro function AddDynamic<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getUFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Add(unreal.FScriptDelegate.createBound($obj, $v{fnName}));
  }

  public static macro function AddUniqueDynamic<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getUFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).AddUnique(unreal.FScriptDelegate.createBound($obj, $v{fnName}));
  }

  public static macro function RemoveDynamic<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getUFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Remove($obj, $v{fnName});
  }

  public static macro function IsAlreadyBound<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getUFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Contains($obj, $v{fnName});
  }

  public static macro function BindDynamic<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getUFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).BindUFunction($obj, $v{fnName});
  }

  public static macro function BindUFunction<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getUFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Internal_BindUFunction($obj, $v{fnName});
  }

  public static macro function AddUFunction<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getUFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Internal_AddUFunction($obj, $v{fnName});
  }

  public static macro function staticVar(e:Expr):Expr {
    return uhx.compiletime.CoreAPIMacros.runStaticVar(e);
  }

  public static macro function staticName(e:Expr):Expr {
    return uhx.compiletime.CoreAPIMacros.runStaticName(e);
  }


#if !macro
  public static var HaxeLog(get, null):LogCategory;

  private static function get_HaxeLog() {
    if (HaxeLog == null) {
      HaxeLog = LogCategory.get("HaxeLog");
    }
    return HaxeLog;
  }

  static var delayedInits:Array<Void->Void>;
  static var hasInit = false;

  /**
    Runs function `fn` after hxcpp static initialization but before any other Unreal code has executed
   **/
  @:noUsing public static function runAtInit(fn:Void->Void) {
    if (hasInit) {
      var msg = 'All `runAtInit` functions should be registered at initialization time (e.g. on `__init__` static functions)';
      trace('Error', msg);
      throw msg;
    } else if (delayedInits == null) {
      delayedInits = [fn];
    } else {
      delayedInits.push(fn);
    }
  }


#if WITH_EDITOR

  static var hotReloadFns:Array<Void->Void>;
  /**
    Runs function `fn` every time hot reload happens
   **/
  @:noUsing public static function onHotReload(fn:Void->Void) {
    if (hotReloadFns == null) {
      hotReloadFns = [fn];
    } else {
      hotReloadFns.push(fn);
    }
  }

#if (WITH_CPPIA || cppia)
  static var cppiaReloadFns:Array<Void->Void>;

  @:noUsing public static function onCppiaReload(fn:Void->Void) {
    if (cppiaReloadFns == null) {
      cppiaReloadFns = [fn];
    } else {
      cppiaReloadFns.push(fn);
    }
  }
#else
  @:noUsing public static function onCppiaReload(fn:Void->Void) {
    trace('Error', 'Trying to add a cppia reload hook, but cppia is not compiled within');
  }
#end
#end

  /**
   * For UObject types, returns the object casted to the input class, or null if the object is null or not of that type.
   * This is meant as a replacement for Cast<Type> in Unreal C++
   * Example:
   *  var actor:AActor = GetOwner();
   *  var pawn:APawn = actor.as(APawn);
   *  if (pawn != null) { ... }
   */
  public static inline function as<T>(obj:UObject, cls:Class<T>) : Null<T> {
    var result:T;
    if (Std.is(obj, cls)) {
      result = cast obj;
    } else
#if cppia
      // because of live reload, we must test as a string
      if (slowAsCheck(obj, cls)) {
        result = cast obj;
      } else
#end
    {
      result = null;
    }
    return result;
  }

  private static function slowAsCheck(obj:UObject, cls:Class<Dynamic>) {
    var target = Type.getClassName(cls);
    var cur:Class<Dynamic> = cast Type.getClass(obj);
    while(cur != null) {
      if (Type.getClassName(cur) == target) {
        return true;
      }
      cur = Type.getSuperClass(cur);
    }
    return false;
  }

#else
  private static function getUFunctionFromObj(args:Array<Expr>):{ obj:Expr, fnName:String } {
    var obj:Expr = null,
        fnName:String = null;
    if (args.length == 1) {
      switch(args[0].expr) {
      case EField(o, s):
        obj = o;
        fnName = s;
      case _:
        throw new Error('Unexpected expression. Expected either a single argument with an UObject field accessor (`obj.field`), or two arguments (`obj, field`)', args[0].pos);
      }
    } else if (args.length == 2) {
      obj = args[0];
      switch(args[1].expr) {
      case EConst(CIdent(s) | CString(s)):
        fnName = s;
      case _:
        throw new Error('Unexpected expression. Expected either a single argument with an UObject field accessor (`obj.field`), or two arguments (`obj, field`)', args[0].pos);
      }
    } else {
      throw new Error('Unexpected number of arguments. Expected either a single argument with an UObject field accessor (`obj.field`), or two arguments (`obj, field`)', Context.currentPos());
    }

    // TODO find function and check if it is a ufunction
    return { obj:obj, fnName:fnName };
  }
#end
}
