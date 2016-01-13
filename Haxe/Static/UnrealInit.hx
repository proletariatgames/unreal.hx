import cpp.link.StaticStd;
import cpp.link.StaticRegexp;
import cpp.link.StaticZlib;
import unreal.*;
import unreal.helpers.HxcppRuntimeStatic;
#if (WITH_CPPIA && WITH_EDITOR)
import unreal.editor.UEditorEngine;
import unreal.developer.hotreload.IHotReloadModule;
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
    var cls:Dynamic = Type.resolveClass('ue4hx.internal.HotReloadStatic');
    if (cls != null) {
      trace('Setting hot reload types');
      cls.bindFunctions();
    }
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
      var watchHandle = FTimerHandle.create();
      var timerDelegate = FTimerDelegate.create();
      timerDelegate.BindLambda(function() {
        var curStat = .0;
        if (FileSystem.exists(target) && (curStat = FileSystem.stat(target).mtime.getTime()) > stamp) {
          trace('reloading cppia...');
          stamp = curStat;
          untyped __global__.__scriptable_load_cppia(sys.io.File.getContent(target));
          var cls:Dynamic = Type.resolveClass('ue4hx.internal.HotReloadScript');
          if (cls != null) {
            trace('Setting cppia hot reload types');
            cls.bindFunctions();
          }
        }
      });
      var hotReloadHandle = null;
      var currentlyCompiling = UEditorEngine.GEditor != null;
      function onHotReload(triggeredAutomatically:Bool) {
        if (currentlyCompiling) {
          // if we're currently compiling, the first hot reload is called right after we've loaded
          currentlyCompiling = false;
        } else {
          if (watchHandle != null) {
            UEditorEngine.GEditor.GetTimerManager().ClearTimer(watchHandle);
            watchHandle = null;
          }
          if (hotReloadHandle != null) {
            IHotReloadModule.Get().OnHotReload().Remove(hotReloadHandle);
            hotReloadHandle = null;
          }
        }
      }

      // add watcher to current editor
      if (unreal.editor.UEditorEngine.GEditor == null) {
        var handle = null;
        handle = FEditorDelegates.RefreshAllBrowsers.AddLambda(function() {
          FEditorDelegates.RefreshAllBrowsers.Remove(handle);
          UEditorEngine.GEditor.GetTimerManager().SetTimer(watchHandle, timerDelegate, 1, true, 0);
          hotReloadHandle = IHotReloadModule.Get().OnHotReload().AddLambda(onHotReload);
        });
      } else {
        UEditorEngine.GEditor.GetTimerManager().SetTimer(watchHandle, timerDelegate, 1, true, 0);
        hotReloadHandle = IHotReloadModule.Get().OnHotReload().AddLambda(onHotReload);
      }
    } else {
      trace('Warning','No compiled cppia file found at $target');
    }
#end
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
