package unreal;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using haxe.macro.Tools;
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

#if !UHX_NO_UOBJECT
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
    var data = getFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Add(unreal.FScriptDelegate.createBound($obj, $v{fnName}));
  }

  public static macro function AddUniqueDynamic<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).AddUnique(unreal.FScriptDelegate.createBound($obj, $v{fnName}));
  }

  public static macro function RemoveDynamic<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Remove($obj, $v{fnName});
  }

  public static macro function IsAlreadyBound<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).Contains($obj, $v{fnName});
  }

  public static macro function BindDynamic<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseDynamicDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getFunctionFromObj(args),
        obj = data.obj,
        fnName = data.fnName;
    return macro (@:privateAccess @:pos(pos) $self.typingHelper($obj.$fnName)).BindUFunction($obj, $v{fnName});
  }

  public static macro function AddDynamicUObject<T:haxe.Constraints.Function>(self:ExprOf<unreal.BaseMulticastDelegate<T>>, args:Array<Expr>) : Expr {
    var pos = Context.currentPos();
    var data = getFunctionFromObj(args, false),
        obj = data.obj,
        fnName = data.fnName;
    var targs = null;
    switch(data.t) {
      case TFun(a,_):
        targs = a;
      case _:
        throw new Error('Unexpected function type ${data.t}', args[0].pos);
    }
    var curArgs = [ for (i in 0...targs.length) 'uhx_arg_$i' ];
    var call = null,
        fn = null;
    call = { expr: ECall(macro $obj.$fnName, [for (m in curArgs) macro $i{m} ]), pos:pos };
    fn = { expr:EFunction(null, {
      args: [ for (arg in curArgs) { name:arg, type:null }],
      expr: macro {
        if (!$obj.isValid() && uhx_delegate_handle != null) {
          $self.Remove(uhx_delegate_handle);
          uhx_delegate_handle = null;
        } else {
          $call;
        }
      },
      ret: null
    }), pos:pos };
    return macro {
      var uhx_delegate_handle = null;
      uhx_delegate_handle = $self.AddLambda($fn);
    }
  }

  @:noUsing public static macro function getTypeUName(type:Expr):ExprOf<String>
  {
    var t = Context.typeof(type);
    switch(Context.follow(t))
    {
      case TAnonymous(anon):
        switch(anon.get().status)
        {
          case AClassStatics(cl):
            var cl = cl.get();
            switch(cl.kind)
            {
              case KAbstractImpl(t):
                return macro $v{uhx.compiletime.tools.MacroHelpers.getUName(t.get())};
              case _:
                return macro $v{uhx.compiletime.tools.MacroHelpers.getUName(cl)};
            }
          case AEnumStatics(t):
            return macro $v{uhx.compiletime.tools.MacroHelpers.getUName(t.get())};
          case AAbstractStatics(t):
            return macro $v{uhx.compiletime.tools.MacroHelpers.getUName(t.get())};
          case _:
        }
      case _:
    }
    throw new Error('Invalid type for getTypeUName $t: Expected a class/enum/abstract', type.pos);
  }

#end // UHX_NO_UOBJECT

  @:noUsing public static macro function staticVar(e:Expr, ?createExpr:Expr):Expr {
    return uhx.compiletime.CoreAPIMacros.runStaticVar(e, createExpr);
  }

  public static macro function staticName(e:ExprOf<String>):Expr {
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

#if !UHX_NO_UOBJECT
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

#end // UHX_NO_UOBJECT

#else
  private static function getFunctionFromObj(args:Array<Expr>, checkUFunction=true):{ obj:Expr, fnName:String, t:Type } {
    if (args == null || args.length == 0) {
      throw new Error('Missing arguments', Context.currentPos());
    }
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

    var pos = args[0].pos;
    var t = Context.typeExpr(macro @:pos(pos) $obj.$fnName);
    if (checkUFunction) {
      switch(t.expr) {
      case TField(_, FInstance(_,_,cf) | FStatic(_,cf) | FClosure(_,cf)):
        if (!cf.get().meta.has(':ufunction')) {
          throw new Error('The function "$fnName" is not a ufunction', pos);
        }
      case e:
        throw new Error('Unexpected expression type $e when getting ufunction', pos);
      }
    }
    return { obj:obj, fnName:fnName, t:Context.follow(t.t) };
  }
#end
}
