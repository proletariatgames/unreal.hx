package ue4hx.internal;
import haxe.CallStack;

/**
  This allows us to make all haxe code run inside a try handler so we can have better error messages
 **/
@:keep class HaxeCodeDispatcher {
  private static var inHaxeCode = false;
  private static var inDebugger = #if (debug && HXCPP_DEBUGGER) true; #else unreal.FPlatformMisc.IsDebuggerPresent(); #end

  @:extern inline public static function runWithValue<T>(fn:Void->T, ?name:String):T {
    if (!inHaxeCode && !inDebugger) {
      inHaxeCode = true;
      try {
        var ret = fn();
        inHaxeCode = false;
        return ret;
      } catch(e:Dynamic) {
        showError(e, CallStack.exceptionStack(), name);
        return cast null;
      }
    } else {
      return fn();
    }
  }

  @:extern inline public static function runVoid(fn:Void->Void, ?name:String):Void {
    if (!inHaxeCode && !inDebugger) {
      inHaxeCode = true;
      try {
        fn();
        inHaxeCode = false;
      } catch(e:Dynamic) {
        showError(e, CallStack.exceptionStack(), name);
      }
    } else {
      fn();
    }
  }

  public static function shouldWrap():Bool {
    var ret = !inHaxeCode && !inDebugger;
    if (ret) {
      inHaxeCode = true;
    }
    return ret;
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
    inHaxeCode = false;
#if WITH_EDITOR
    var world = unreal.UEngine.GWorld.GetReference();
    if (world == null || !world.IsPlayInEditor())
#end
    {
    unreal.Log.fatal('Haxe run failed');
    throw 'Error';
    }
  }
}
