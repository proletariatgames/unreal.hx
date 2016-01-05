import cpp.link.StaticStd;
import cpp.link.StaticRegexp;
import cpp.link.StaticZlib;
import unreal.UObject;
import unreal.AActor;
import unreal.helpers.HxcppRuntimeStatic;

// this code is needed on windows since we're compiling with -MT instead of -MD
@:cppFileCode("#ifdef HX_WINDOWS\nextern char **environ = NULL;\n#endif\n")
@:access(unreal.CoreAPI)
class UnrealInit
{
  static var delayedInits:Array<Void->Void>;

  static function main()
  {
    haxe.Log.trace = customTrace;
    var delayed = unreal.CoreAPI.delayedInits;
    unreal.CoreAPI.hasInit = true;
    if (delayed != null) {
      for (delayed in delayed) {
        delayed();
      }
    }

    trace("initializing unreal haxe");
  }

  static var oldTrace = haxe.Log.trace;

  static function customTrace(v:Dynamic, ?infos:haxe.PosInfos) {
    var str:String = null;
    if (infos != null) {
      str = infos.fileName + ":" + infos.lineNumber + ": ";
      if (infos.customParams != null && infos.customParams.length > 0) {
        switch (Std.string(v).toUpperCase()) {
        case "LOG":
          unreal.Log.trace(str + infos.customParams.join(','));
        case "WARNING":
          unreal.Log.warning(str + infos.customParams.join(','));
        case "ERROR":
          unreal.Log.error(str + infos.customParams.join(','));
        case "FATAL":
          unreal.Log.fatal(str + infos.customParams.join(','));
        case _:
          unreal.Log.trace(str + v + ',' + infos.customParams.join(','));
        }
      } else {
        unreal.Log.trace(str + v);
      }
    } else {
      unreal.Log.trace(Std.string(v));
    }
  }
}
