package uhx;
#if !macro
import haxe.CallStack;
import unreal.FPlatformMisc;

/**
  This allows us to make all haxe code run inside a try handler so we can have better error messages
 **/
@:keep class HaxeCodeDispatcher {
  private static var inHaxeCode = false;

  @:extern inline public static function ensureMainThread()
  {
    #if !UHX_NO_UOBJECT
    uhx.ue.RuntimeLibrary.ensureMainThread();
    #end
  }

  @:extern inline public static function runWithValue<T>(fn:Void->T, ?name:String):T {
    ensureMainThread();
    #if (UE_BUILD_SHIPPING && !debug && !HXCPP_STACK_TRACE)
    return fn();
    #else
    if (shouldWrap()) {
      try {
        var ret = fn();
        endWrap();
        return ret;
      } catch(e:Dynamic) {
        showError(e, CallStack.exceptionStack(), name);
        return cast null;
      }
    } else {
      return fn();
    }
    #end
  }

  @:extern inline public static function runVoid(fn:Void->Void, ?name:String):Void {
    ensureMainThread();
    #if (UE_BUILD_SHIPPING && !debug && !HXCPP_STACK_TRACE)
    fn();
    #else
    if (shouldWrap()) {
      try {
        fn();
        endWrap();
      } catch(e:Dynamic) {
        showError(e, CallStack.exceptionStack(), name);
      }
    } else {
      fn();
    }
    #end
  }

  public static function shouldWrap():Bool {
    #if (UE_BUILD_SHIPPING && !debug && !HXCPP_STACK_TRACE)
    return false;
    #else
    var ret = !inHaxeCode;
    if (ret) {
      inHaxeCode = true;
    }
    return ret;
    #end
  }

  inline public static function endWrap() {
    inHaxeCode = false;
  }

  public static function showError(exc:Dynamic, stack:Array<StackItem>, name:String) {
    if (name != null) {
      trace('Error', '$name: $exc');
    } else {
      trace('Error', exc);
    }
    trace('Error', 'Stack trace:\n' + CallStack.toString(stack));

    if (FPlatformMisc.IsDebuggerPresent()) {
      FPlatformMisc.DebugBreak();
    }
#if (debug && HXCPP_DEBUGGER && hxcpp_debugger_ext)
    debugger.Api.debugBreak();
#end
    endWrap();
    var inPIE = false;
#if WITH_EDITOR
    var world = unreal.UEngine.GWorld.GetReference();
    if (world != null && world.IsPlayInEditor()) {
      inPIE = true;
    } else {
      var engine = unreal.UEngine.GEngine;
      if (engine != null) {
        var ctxs = engine.GetWorldContexts();
        for (i in 0...ctxs.Num()) {
          var ctx = ctxs.get_Item(i);
          if (ctx.WorldType.match(PIE) && ctx.World() != null) {
            inPIE = true;
            break;
          }
        }
      }
    }
#end
    if (!inPIE)
    {
      unreal.Log.fatal('Haxe run failed');
      throw 'Error';
    }
  }
}
#end