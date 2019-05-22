#if !UHX_NO_UOBJECT
import unreal.TMap;
import unreal.TArray;
import unreal.TSet;
#end
import unreal.*;

#if WITH_EDITOR
import uhx.expose.HxcppRuntime;
import uhx.HaxeCodeDispatcher;
import unreal.developer.directorywatcher.*;
import unreal.developer.hotreload.IHotReloadModule;
import unreal.editor.*;
import unreal.editor.UEditorEngine;
import unreal.FTimerManager;
import sys.FileSystem;

using Lambda;
using StringTools;
#end

// this code is needed on windows since we're compiling with -MT instead of -MD
@:buildXml("<compilerflag value=\"/bigobj\" if=\"windows\" /><compilerflag value=\"${UHX_EXTRA_COMPILERFLAGS}\" /> <files id=\"cppia\"><compilerflag value=\"${UHX_EXTRA_COMPILERFLAGS}\" /> <compilerflag value=\"/bigobj\" if=\"windows\" /> </files>")
@:access(unreal.CoreAPI)
class UnrealInit
{
#if (debug && HXCPP_DEBUGGER)
  static var debugTick:Dynamic;
#end

  static function main()
  {
    #if !UHX_NO_CUSTOM_TRACE
    haxe.Log.trace = customTrace;
    #end
    trace("initializing unreal haxe");

#if (debug && HXCPP_DEBUGGER)
#if hxcpp_debugger_ext
    // debugger.Api.addRuntimeClassData();
    debugger.Api.setMyClassPaths();
    var ping = debugger.VSCodeRemote.start('localhost');
    if (!ping.isConnected) {
      debugTick = FTickerDelegate.create();
      var lastCheckTime = 3.0;
      (debugTick : FTickerDelegate).BindLambda(function(deltaTime) {
        if (!ping.isConnected && (lastCheckTime += deltaTime) >= 3 ) {
          lastCheckTime = .0;
          ping.attemptToConnect();
        }
        return true;
      });
      FTicker.GetCoreTicker().AddTicker((debugTick : FTickerDelegate), 3);
    }
#else
    if (Sys.getEnv("HXCPP_DEBUG") != null) {
      new debugger.HaxeRemote(true, "localhost");
    }
#end
#end // (debug && HXCPP_DEBUGGER)

#if WITH_EDITOR
    try {
      if (unreal.CoreAPI.hotReloadFns == null) {
        unreal.CoreAPI.hotReloadFns = [];
      }

      editorSetup();
    } catch(e:Dynamic) {
      FMessageDialog.Open(Ok, 'Error while setting up the editor: $e', 'Unreal.hx initialization error');
      trace('Error', 'Error while setting up the editor: $e');
      trace('Error', haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
    }
#end // WITH_EDITOR

    var delayed = unreal.CoreAPI.delayedInits;
    unreal.CoreAPI.hasInit = true;
    var cls:Dynamic = Type.resolveClass('uhx.LiveReloadStatic');
    if (cls != null) {
      cls.bindFunctions();
    }
    if (delayed != null) {
      for (delayed in delayed) {
        delayed();
      }
    }

#if !UHX_NO_UOBJECT
    uhx.ue.ClassMap.runInits();
#end
  }

#if WITH_EDITOR

  static function editorSetup() {
    // get game path
    var gameDir = FPaths.ConvertRelativePathToFull(FPaths.ProjectDir()).toString();
    var target = '$gameDir/Binaries/Haxe/game.cppia';
    var stamp = .0;
    var internalStamp = .0;

    var disabled = false,
        waitingRebind = false;
#if WITH_CPPIA
    var metaClass = Type.resolveClass('uhx.meta.StaticMetaData');
    if (metaClass != null) {
      var metas = haxe.rtti.Meta.getType(metaClass).UTypes;
      if (metas != null) {
        for (meta in metas) {
          uhx.runtime.UReflectionGenerator.initializeStaticMeta(meta);
        }
      }
    }

    var first = true;
    function loadCppia() {
#if DEBUG_HOTRELOAD
      trace('${uhx.runtime.UReflectionGenerator.id}: loading cppia');
#end // DEBUG_HOTRELOAD
      var success = false,
          contents = null,
          loadPrevious = false,
          errorContents = null;
      try {
        var oldData = uhx.ue.RuntimeLibraryDynamic.getAndFlushPrintf();
        if (oldData.length > 0) {
          oldData = oldData.split('\n').filter(function(v) return v.indexOf('Get static field not found') < 0 && v.trim() != '').join('\n');
        }
        if (oldData.length > 0) {
          trace('printf buffer: $oldData');
        }

        contents = sys.io.File.getContent(target);
        untyped __global__.__scriptable_load_cppia(contents);
#if (debug && HXCPP_DEBUGGER && hxcpp_debugger_ext)
        debugger.Api.refreshCppiaDefinitions();
#end
        errorContents = uhx.ue.RuntimeLibraryDynamic.getAndFlushPrintf();
        if (errorContents.length > 0) {
          trace('Warning', 'Warnings while loading cppia:\n$errorContents');
        }

        var cls:Dynamic = Type.resolveClass('uhx.LiveReloadScript');
        if (cls != null) {
          trace('Setting cppia live reload types');
          cls.bindFunctions();
        }
        cls = Type.resolveClass('uhx.meta.CppiaCompilation');
        if (cls != null) {
          var newStamp:Float = cls.timestamp;
          if (Math.abs(newStamp - internalStamp) < .1) {
            var msg = 'There seems to be an error loading the new cppia script, as the last built script has the same timestamp as the current. Ignore this if the output file had its timestamp updated, ' +
                      'but it wasn\'t recompiled. Otherwise, please check your UE4Editor console (stdout log) to have more information on the error';
            FMessageDialog.Open(Ok, msg, 'Unreal.hx cppia initialization error');
            trace('Error', msg);
          } else if (newStamp < internalStamp) {
            trace('Warning', 'Newly loaded cppia script seems to be older than last version: ${Date.fromTime(newStamp)} and ${Date.fromTime(internalStamp)}');
          } else {
            success = true;
          }
          internalStamp = newStamp;
        }

#if !NO_DYNAMIC_UCLASS
        var metaClass = Type.resolveClass('uhx.meta.CppiaMetaData');
        if (metaClass != null) {
          var metadata = haxe.rtti.Meta.getType(metaClass);
          var metas:Array<Dynamic> = metadata.UDelegates;
          if (metas != null) {
            for (del in metas) {
              uhx.runtime.UReflectionGenerator.initializeDelegate(del);
            }
          }
          var metas:Array<{ haxeClass:String, uclass:String }> = cast metadata.DynamicClasses,
              map = new Map();
          if (metas != null) {
            for (c in metas) {
              var hxClass:Dynamic = Type.resolveClass(c.haxeClass);
              if (hxClass != null) {
                var meta = haxe.rtti.Meta.getType(hxClass).UMetaDef;
                map[c.uclass] = { haxeClass:c.haxeClass, meta:meta[0], uclass:c.uclass };
              }
            }

            // make sure we add the definitions in the right order
            // this should already be in the right order (see MetaDefBuild)
            // but it's best to make sure
            function recurse(arg:{ haxeClass:String, uclass:String, meta:uhx.meta.MetaDef }) {
              var meta = arg.meta;
              var parent = map[meta.uclass.superStructUName];
              if (parent != null) {
                recurse(parent);
              }
              map.remove(arg.uclass);
              uhx.runtime.UReflectionGenerator.initializeDef(arg.uclass, arg.haxeClass, meta);
            }
            for (c in metas) {
              if (map.exists(c.uclass)) {
                recurse(map[c.uclass]);
              }
            }
          }
        } else {
          trace('Warning', 'Could not find cppia metadata');
        }
#end // !NO_DYNAMIC_UCLASS
        if (first) {
          first = false;
        } else {
          if (!disabled) {
            switch(uhx.runtime.UReflectionGenerator.cppiaHotReload()) {
            case WaitingRebind:
              waitingRebind = true;
            case Success:
              var reloadFns = unreal.CoreAPI.cppiaReloadFns;
              if (reloadFns != null && reloadFns.length > 0) {
                unreal.CoreAPI.cppiaReloadFns = [];
                for (fn in reloadFns) {
                  fn();
                }
              }
            case Failure:
              FMessageDialog.Open(Ok, 'Unreal.hx cppia hot reload failure', 'Unreal.hx error');
              trace('Error', 'Hot reload failure');
              success = false;
            }
          }
        }
      } catch(e:Dynamic) {
        if (errorContents == null) {
          errorContents = uhx.ue.RuntimeLibraryDynamic.getAndFlushPrintf();
        }

        trace('Error', 'Error while loading cppia: $e\nError details: $errorContents');
        trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
        FMessageDialog.Open(Ok, 'Error while loading cppia: $e\n$errorContents', 'Unreal.hx cppia error');
        loadPrevious = true;
        success = false;
      }
      stamp = FileSystem.stat(target).mtime.getTime();

      var workingTarget = '$gameDir/Binaries/Haxe/game-working.cppia';
      if (success) {
        if (contents != null) {
          try {
            sys.io.File.saveContent(workingTarget, contents);
          }
          catch(e:Dynamic) {
            trace('Error', 'Error while saving $workingTarget: $e');
          }
        }
      } else if (loadPrevious && FileSystem.exists(workingTarget)) {
        try {
          trace('Cppia load failed - loading previously working file');
          untyped __global__.__scriptable_load_cppia(sys.io.File.getContent(workingTarget));
        }
        catch(e:Dynamic) {
          FMessageDialog.Open(Ok, 'Error while loading previously working cppia script: $e', 'Unreal.hx cppia error');
        }
      }
    }

    if (sys.FileSystem.exists(target)) {
      loadCppia();
    } else {
      trace('Warning','No compiled cppia file found at $target');
    }

    // add file watcher
    var dirWatchHandle:FTickerDelegate = null;
#end // WITH_CPPIA

    var hotReloadHandle = null,
        onCompHandle = null,
        onBeginCompHandle = null;
    var shouldCleanup = false;
    function onBeginCompilation(async:Bool) {
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
      if (shouldCleanup || waitingRebind) {
#if DEBUG_HOTRELOAD
        trace('${uhx.runtime.UReflectionGenerator.id}: Hot reload detected');
#else // DEBUG_HOTRELOAD
        trace('Hot reload detected');
#end // DEBUG_HOTRELOAD

#if WITH_CPPIA
        if (dirWatchHandle != null) {
          dirWatchHandle.Unbind();
          dirWatchHandle.dispose();
          dirWatchHandle = null;
        }
#end // WITH_CPPIA

#if (debug && HXCPP_DEBUGGER)
        if (debugTick != null) {
          (debugTick : FTickerDelegate).Unbind();
          (debugTick : FTickerDelegate).dispose();
          debugTick = null;
        }
#end // debug && HXCPP_DEBUGGER

        if (hotReloadHandle != null) {
          IHotReloadModule.Get().OnHotReload().Remove(hotReloadHandle);
          hotReloadHandle = null;
        }

        for (fn in unreal.CoreAPI.hotReloadFns) {
          fn();
        }
#if WITH_CPPIA
        if (waitingRebind) {
          var reloadFns = unreal.CoreAPI.cppiaReloadFns;
          if (reloadFns != null && reloadFns.length > 0) {
            unreal.CoreAPI.cppiaReloadFns = [];
            for (fn in reloadFns) {
              fn();
            }
          }
        }
      } else {
        uhx.runtime.UReflectionGenerator.onHotReload();
#end // WITH_CPPIA
      }
    }

#if WITH_CPPIA
    var dirWatchHandle = FTickerDelegate.create();
#if WITH_LIVE_RELOAD
    var lastLiveStamp = Date.now().getTime();
    var liveTarget = '$gameDir/Binaries/Haxe/live.cppia';
#end
    dirWatchHandle.BindLambda(function(deltaTime) {
      if (FileSystem.exists(target) && FileSystem.stat(target).mtime.getTime() > stamp) {
        if (waitingRebind) {
#if DEBUG_HOTRELOAD
          trace('${uhx.runtime.UReflectionGenerator.id}: Disabling watch: waiting for hot reload rebind');
#end // DEBUG_HOTRELOAD
          return false;
        }

        if (!disabled) {
          loadCppia();
        }
      }
#if WITH_LIVE_RELOAD
      var latestStamp = 0.0;
      if (FileSystem.exists(liveTarget) && (latestStamp = FileSystem.stat(liveTarget).mtime.getTime()) > lastLiveStamp)
      {
        try {
          var oldData = uhx.ue.RuntimeLibraryDynamic.getAndFlushPrintf();
          if (oldData.length > 0) {
            oldData = oldData.split('\n').filter(function(v) return v.indexOf('Get static field not found') < 0 && v.trim() != '').join('\n');
          }
          if (oldData.length > 0) {
            trace('printf buffer: $oldData');
          }
          trace('loading live functions');

          var contents = sys.io.File.getContent(liveTarget);
          untyped __global__.__scriptable_load_cppia(contents);
          var errorContents = uhx.ue.RuntimeLibraryDynamic.getAndFlushPrintf();
          if (errorContents.length > 0) {
            trace('Warning', 'Warnings while loading cppia:\n$errorContents');
          }

          var cls:Dynamic = Type.resolveClass('uhx.LiveReloadLive');
          if (cls != null) {
            trace('Setting cppia live reload types');
            cls.bindFunctions();
          }
        }
        catch(e:Dynamic)
        {
          trace('Error', 'Error while loading live reload types: $e');
        }
        lastLiveStamp = latestStamp;
      }
#end

      return true;
    });

    FTicker.GetCoreTicker().AddTicker(dirWatchHandle, 2);
#end // WITH_CPPIA

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

  static function getPluginDir() {
    var manager = unreal.projects.IPluginManager.Get();
    if (manager == null) {
      FMessageDialog.Open(Ok, 'Cannot determine the plugin directory, as the plugin manager is not enabled', 'Unreal.hx Error');
      return null;
    }

    var plg = manager.FindPlugin("UnrealHx");
    if (plg == null || plg.Get() == null) {
      FMessageDialog.Open(Ok, 'Cannot determine the plugin directory, as the "UnrealHx" plugin was not found. Make sure it is installed as a plugin on your project', 'Unreal.hx Error');
      return null;
    }

    return FPaths.ConvertRelativePathToFull(plg.Get().GetBaseDir()).toString();
  }

#end // WITH_EDITOR

  static var oldTrace = haxe.Log.trace;

  static function customTrace(v:Dynamic, ?infos:haxe.PosInfos) {
    var str:String = null;
    if (infos != null) {
      str = infos.fileName + ":" + infos.lineNumber + ": ";
      if (infos.customParams == null) {
        // fast path
        unreal.Log.trace(str + v);
      } else {
        var idx = -1;
        var cat:unreal.LogCategory = null;
        if (Std.is(v, unreal.LogCategory)) {
          cat = v;
          idx++;
        }
        var verbosity = unreal.ELogVerbosity.Log;
        var val:Dynamic = idx < 0 ? v : infos.customParams[0];
        if (Std.is(val, unreal.ELogVerbosity)) {
          verbosity = val;
          idx++;
        } else {
          switch (Std.string(val).toUpperCase()) {
          case "LOG":
            verbosity = Log;
            idx++;
          case "WARNING":
            verbosity = Warning;
            idx++;
          case "ERROR":
            verbosity = Error;
            idx++;
          case "FATAL":
            verbosity = Fatal;
            idx++;
          case "DISPLAY":
            verbosity = Display;
            idx++;
          case "VERBOSE":
            verbosity = Verbose;
            idx++;
          case "VERYVERBOSE":
            verbosity = VeryVerbose;
            idx++;
          case _:
          }
        }

        if (idx < 0) {
          str += v + ',' + infos.customParams.join(',');
        } else if (idx == 0) {
          str += infos.customParams.join(',');
        } else {
          str += infos.customParams.slice(idx, null).join(',');
        }

        if (cat == null) {
          switch(verbosity) {
          case Fatal:
            unreal.Log.error(str);
            unreal.Log.error('Stack trace:\n' + haxe.CallStack.toString(haxe.CallStack.callStack()));
            unreal.Log.fatal(str);
          case _:
            unreal.FMsg.Logf(infos.fileName, infos.lineNumber, unreal.CoreAPI.staticName("HaxeLog"), verbosity, str);
          }
        } else if (!cat.unrealCategory.IsSuppressed(verbosity)) {
          if (verbosity == Fatal) {
            unreal.FMsg.Logf(infos.fileName, infos.lineNumber, cat.name, Error, str);
            unreal.FMsg.Logf(infos.fileName, infos.lineNumber, cat.name, Error, 'Stack trace:\n' + haxe.CallStack.toString(haxe.CallStack.callStack()));
          }
          unreal.FMsg.Logf(infos.fileName, infos.lineNumber, cat.name, verbosity, str);
        }
      }
    } else {
      unreal.Log.trace(Std.string(v));
    }
  }
}
