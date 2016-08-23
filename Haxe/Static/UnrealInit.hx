import cpp.link.StaticStd;
import cpp.link.StaticRegexp;
import cpp.link.StaticZlib;
#if WITH_EDITOR
import unreal.*;
import unreal.helpers.HxcppRuntime;
import ue4hx.internal.HaxeCodeDispatcher;
import unreal.editor.UEditorEngine;
import unreal.developer.hotreload.IHotReloadModule;
import unreal.FTimerManager;
import unreal.editor.*;
import sys.FileSystem;
import unreal.developer.directorywatcher.*;
#end

// this code is needed on windows since we're compiling with -MT instead of -MD
@:cppFileCode("#ifndef environ\n#ifdef HX_WINDOWS\nextern char **environ = NULL;\n#endif\n#endif\n")
@:access(unreal.CoreAPI)
class UnrealInit
{
  static function main()
  {
    haxe.Log.trace = customTrace;
    trace("initializing unreal haxe");

#if (debug && HXCPP_DEBUGGER)
    if (Sys.getEnv("HXCPP_DEBUG") != null) {
      new debugger.HaxeRemote(true, "localhost");
    }
#end

#if WITH_EDITOR
    try {
      if (unreal.CoreAPI.hotReloadFns == null) {
        unreal.CoreAPI.hotReloadFns = [];
      }

      editorSetup();
    } catch(e:Dynamic) {
      trace('Error', 'Error while setting up the editor: $e');
      trace('Error', haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
    }
#end

    var delayed = unreal.CoreAPI.delayedInits;
    unreal.CoreAPI.hasInit = true;
    var cls:Dynamic = Type.resolveClass('ue4hx.internal.LiveReloadStatic');
    if (cls != null) {
      cls.bindFunctions();
    }
    if (delayed != null) {
      for (delayed in delayed) {
        delayed();
      }
    }
  }

#if WITH_EDITOR

  static function editorSetup() {
    // get game path
    var gameDir = FPaths.ConvertRelativePathToFull(FPaths.GameDir()).toString();
    var target = '$gameDir/Binaries/Haxe/game.cppia';
    var stamp = .0;
    var internalStamp = .0;

    var disabled = false;
#if WITH_CPPIA
    function loadCppia() {
      trace('loading cppia');
      try {
        untyped __global__.__scriptable_load_cppia(sys.io.File.getContent(target));
        var cls:Dynamic = Type.resolveClass('ue4hx.internal.LiveReloadScript');
        if (cls != null) {
          trace('Setting cppia live reload types');
          cls.bindFunctions();
        }
        cls = Type.resolveClass('ue4hx.internal.CppiaCompilation');
        if (cls != null) {
          var newStamp:Float = cls.timestamp;
          if (Math.abs(newStamp - internalStamp) < .1) {
            trace('Error', 'There seems to be an error loading the new cppia script, as the last built script has the same timestamp as the current. Ignore this if the output file had its timestamp updated, ' +
                  'but it wasn\'t recompiled. Otherwise, please check your UE4Editor console (stdout log) to have more information on the error');
          } else if (newStamp < internalStamp) {
            trace('Warning', 'Newly loaded cppia script seems to be older than last version: ${Date.fromTime(newStamp)} and ${Date.fromTime(internalStamp)}');
          }
          internalStamp = newStamp;
        }
      } catch(e:Dynamic) {
        trace('Error', 'Error while loading cppia: $e');
      }
      stamp = FileSystem.stat(target).mtime.getTime();
    }

    if (sys.FileSystem.exists(target)) {
      loadCppia();
    } else {
      trace('Warning','No compiled cppia file found at $target');
    }

    // add file watcher
    var dirWatchHandle:FTickerDelegate = null;
#end

    var hotReloadHandle = null,
        onCompHandle = null,
        onBeginCompHandle = null;
    var shouldCleanup = false;
    function onBeginCompilation(_) {
      trace('begin compilation');
      disabled = true;
    }

    // when we finish compiling, we check if we should invalidate the current module
    function onCompilation(_, result:ECompilationResult, _) {
      shouldCleanup = shouldCleanup || result == Succeeded;
      if (shouldCleanup) {
        // invalidate our own handles - we won't need it anymore
        if (onCompHandle != null) {
          IHotReloadModule.Get().OnModuleCompilerFinished().Remove(onCompHandle);
          onCompHandle = null;
        }
        if (onBeginCompHandle != null) {
          IHotReloadModule.Get().OnModuleCompilerStarted().Remove(onBeginCompHandle);
          onBeginCompHandle = null;
        }
      } else {
        disabled = false;
      }
    }

    // if we should invalidate the current module, invalidate all active ahdnles
    function onHotReload(triggeredAutomatically:Bool) {
      if (shouldCleanup) {
        trace('Hot reload detected');
#if WITH_CPPIA
        if (dirWatchHandle != null) {
          dirWatchHandle.Unbind();
          dirWatchHandle.dispose();
          dirWatchHandle = null;
        }
#end
        if (hotReloadHandle != null) {
          IHotReloadModule.Get().OnHotReload().Remove(hotReloadHandle);
          hotReloadHandle = null;
        }

        for (fn in unreal.CoreAPI.hotReloadFns) {
          fn();
        }
      }
    }

#if WITH_CPPIA
    var dirWatchHandle = FTickerDelegate.create();
    dirWatchHandle.BindLambda(function(deltaTime) {
      if (FileSystem.exists(target) && FileSystem.stat(target).mtime.getTime() > stamp) {
        if (!disabled) {
          loadCppia();
        }
      }

      return true;
    });

    FTicker.GetCoreTicker().AddTicker(dirWatchHandle, 2);
#end

    function addWatcher() {
      hotReloadHandle = IHotReloadModule.Get().OnHotReload().AddLambda(onHotReload);
      onCompHandle = IHotReloadModule.Get().OnModuleCompilerFinished().AddLambda(onCompilation);
      onBeginCompHandle = IHotReloadModule.Get().OnModuleCompilerStarted().AddLambda(onBeginCompilation);
    }

    // add watcher to current editor
    if (unreal.editor.UEditorEngine.GEditor == null) {
      var handle = null;
      handle = FEditorDelegates.RefreshAllBrowsers.AddLambda(function() {
        FEditorDelegates.RefreshAllBrowsers.Remove(handle);
        addWatcher();
      });
    } else {
      addWatcher();
    }
  }
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
          unreal.Log.error(str + infos.customParams.join(','));
          unreal.Log.error('Stack trace:\n' + haxe.CallStack.toString(haxe.CallStack.callStack()));
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
