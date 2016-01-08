import cpp.link.StaticStd;
import cpp.link.StaticRegexp;
import cpp.link.StaticZlib;
import unreal.*;
import unreal.helpers.HxcppRuntimeStatic;
#if (WITH_CPPIA && WITH_EDITOR)
import unreal.FTimerManager;
import unreal.editor.*;
import sys.FileSystem;
#end

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
#if (WITH_CPPIA && WITH_EDITOR)
    // get game path
    var gameDir = FPaths.ConvertRelativePathToFull(FPaths.GameDir()).toString();
    var target = '$gameDir/Binaries/Haxe/game.cppia';
    if (sys.FileSystem.exists(target)) {
      trace('loading cppia');
      untyped __global__.__scriptable_load_cppia(sys.io.File.getContent(target));
      var stamp = FileSystem.stat(target).mtime.getTime();
      // add file watcher
      var handle = null;
      handle = FEditorDelegates.RefreshAllBrowsers.AddLambda(function() {
        FEditorDelegates.RefreshAllBrowsers.Remove(handle);

        watchHandle = FTimerHandle.create();
        var delegate = FTimerDelegate.create();
        delegate.BindLambda(function() {
          var curStat = .0;
          if (FileSystem.exists(target) && (curStat = FileSystem.stat(target).mtime.getTime()) > stamp) {
            trace('reloading cppia...');
            stamp = curStat;
            untyped __global__.__scriptable_load_cppia(sys.io.File.getContent(target));
          }
        });
        unreal.editor.UEditorEngine.GEditor.GetTimerManager().SetTimer(watchHandle, delegate, 1, true, 0);
      });
    } else {
      trace('Warning','No compiled cppia file found at $target');
    }
#end
  }
#if (WITH_CPPIA && WITH_EDITOR)
  static var watchHandle:FTimerHandle;
  static var fn;
#end

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
