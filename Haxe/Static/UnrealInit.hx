#if WITH_EDITOR
import uhx.expose.HxcppRuntime;
import uhx.HaxeCodeDispatcher;
import unreal.*;
import unreal.developer.directorywatcher.*;
import unreal.developer.hotreload.IHotReloadModule;
import unreal.editor.*;
import unreal.editor.UEditorEngine;
import unreal.FTimerManager;
import sys.FileSystem;
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

    uhx.ue.ClassMap.runInits();
  }

#if WITH_EDITOR

  static function editorSetup() {
    // get game path
    var gameDir = FPaths.ConvertRelativePathToFull(FPaths.GameDir()).toString();
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
          loadPrevious = false;
      try {
        contents = sys.io.File.getContent(target);
        untyped __global__.__scriptable_load_cppia(contents);
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
        FMessageDialog.Open(Ok, 'Error while loading cppia: $e', 'Unreal.hx cppia error');
        trace('Error', 'Error while loading cppia: $e');
        trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
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
      // let Haxe compile
      var ret = null;
      try {
        if (FileSystem.exists('$gameDir/Intermediate/Haxe/skip-editor.txt')) {
          FileSystem.deleteFile('$gameDir/Intermediate/Haxe/skip-editor.txt');
        }
        if (FileSystem.exists('$gameDir/Intermediate/Haxe/skip.txt')) {
          FileSystem.deleteFile('$gameDir/Intermediate/Haxe/skip.txt');
        }
#if WITH_CPPIA
        // try to compile only cppia first
        ret = compileHaxe(true);
        if (ret.needsFull) {
          trace('Sources need a full compilation');
          ret = compileHaxe(false, ['-D','UE_SKIP_BAKE']);
        }
#else
        ret = compileHaxe(false);
#end

        var gameDir = FPaths.ConvertRelativePathToFull(FPaths.GameDir()).toString();
        if (FileSystem.exists('$gameDir/Intermediate/Haxe')) {
          FileSystem.createDirectory('$gameDir/Intermediate/Haxe');
        }

        if (ret.success) {
          trace('Skipping haxe compilation');
          Sys.putEnv("UHX_COMPILATION_SUCCESS", "1");
          sys.io.File.saveContent('$gameDir/Intermediate/Haxe/skip-editor.txt', '1');
        } else {
          Sys.putEnv("UHX_COMPILATION_SUCCESS", "0");
          sys.io.File.saveContent('$gameDir/Intermediate/Haxe/skip-editor.txt', 'fail');
        }
      }
      catch(e:Dynamic) {
        trace('Error', 'Fatal error while trying to compile Haxe sources: $e');
        trace('Error', haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
      }
    }

    // when we finish compiling, we check if we should invalidate the current module
    function onCompilation(_, result:ECompilationResult, _) {
      if (FileSystem.exists('$gameDir/Intermediate/Haxe/skip-editor.txt')) {
        FileSystem.deleteFile('$gameDir/Intermediate/Haxe/skip-editor.txt');
      }
      if (FileSystem.exists('$gameDir/Intermediate/Haxe/skip.txt')) {
        FileSystem.deleteFile('$gameDir/Intermediate/Haxe/skip.txt');
      }
      switch(result) {
      case CrashOrAssert | OtherCompilationError | Unsupported | Unknown:
        Sys.putEnv("UHX_COMPILATION_SUCCESS", "0");
      case _:
        if (Sys.getEnv("UHX_COMPILATION_SUCCESS") == "1") {
          trace('Compilation succeeded');
#if WITH_CPPIA
          var gameDir = FPaths.ConvertRelativePathToFull(FPaths.GameDir()).toString();
          var editorTarget = '$gameDir/Binaries/Haxe/game-editor.cppia',
              target = '$gameDir/Binaries/Haxe/game.cppia';
          if (Sys.getEnv("UHX_COMPILATION_SUCCESS") == "1" && FileSystem.exists(target)) {
            if (!FileSystem.exists(target) || FileSystem.stat(target).mtime.getTime() < FileSystem.stat(editorTarget).mtime.getTime()) {
              trace('Copying $editorTarget to $target');
              sys.io.File.copy(editorTarget, target);
            }
          }
#end // WITH_CPPIA
        }
      }

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

  static function compileHaxe(cppiaOnly:Bool, ?additionalArguments:Array<String>) {
    var pluginPath = getPluginDir();
    if (pluginPath == null) {
      trace('Error', 'No plugin dir was found while compiling Haxe. Instead, we will ensure that the normal compiler runs');
      trace('Error', 'Please review why the plugin directory was not found, and if you believe this is an error, report this');

      var sourceDir = FPaths.ConvertRelativePathToFull(FPaths.GameSourceDir());
      sys.io.File.saveContent('$sourceDir/Generated.Build.cs', '// do not save this file on your source control. This is generated to make sure that Haxe will compile when the plugin directory cannot be determined');
      return { success:true, needsFull:false };
    }

    var compServer = Sys.getEnv('HAXE_COMPILATION_SERVER');
    if (compServer != null && compServer != '') {
      Sys.putEnv('HAXE_COMPILATION_SERVER', null);
      Sys.putEnv('HAXE_COMPILATION_SERVER_DEFER', compServer);
    }
    var gameDir = FPaths.ConvertRelativePathToFull(FPaths.GameDir()),
        engineDir = FPaths.ConvertRelativePathToFull(FPaths.EngineDir()),
        projectFile = FPaths.ConvertRelativePathToFull(FPaths.GetProjectFilePath()),
        targetName = FApp.GetGameName().toString(), // TODO what about the Editor ?
        targetType = 'Editor',
        targetPlatform = FPlatformMisc.GetUBTPlatform(),
        targetConfiguration = FModuleManager.GetUBTConfiguration();

    var args = [
      '--cwd', '$pluginPath/Haxe/BuildTool', 'compile-project.hxml',
      '-D', 'UE_EDITOR_COMPILE',
      '-D', 'EngineDir=$engineDir',
      '-D', 'ProjectDir=$gameDir',
      '-D', 'TargetName=$targetName',
      '-D', 'TargetPlatform=$targetPlatform',
      '-D', 'TargetConfiguration=$targetConfiguration',
      '-D', 'TargetType=$targetType',
      '-D', 'ProjectFile=$projectFile',
      '-D', 'PluginDir=$pluginPath',
    ];
    var lastCompSuccess = Sys.getEnv("UHX_COMPILATION_SUCCESS") == "1";
    if (lastCompSuccess) {
      args.push('-D');
      args.push('UE_EDITOR_RECOMPILE');
    }

#if WITH_CPPIA
    if (cppiaOnly && (lastCompSuccess || Sys.getEnv("UHX_COMPILATION_SUCCESS") == null)) {
      trace('Trying to compile cppia only first');
      args.push('-D');
      args.push('UE_CPPIA_RECOMPILE');
    }
#else
    cppiaOnly = false;
#end
    if (additionalArguments != null) {
      args = args.concat(additionalArguments);
    }

    trace('Calling Haxe compiler with arguments: "${args.join('" "')}"');
    var proc = null;
    try {
      proc = new sys.io.Process('haxe', args);
    }
    catch(e:Dynamic) {
      trace('Error', 'Haxe compilation failed: $e!');
      return { success:false, needsFull:false };
    }

    var needsFull = false;
    function read(name:String, inp:haxe.io.Input) {
      cpp.vm.Thread.create(function() {
        try {
          while(true) {
            var ln = inp.readLine();
            if (cppiaOnly) {
              if (ln.indexOf('UHXERR') >= 0) {
                needsFull = true;
              }
            }
            if (ln.indexOf('Warning') >= 0) {
              unreal.Log.warning(ln);
            } else if (ln.indexOf('Error') >= 0) {
              unreal.Log.error(ln);
            } else {
              unreal.Log.trace(ln);
            }
          }
        }
        catch(e:haxe.io.Eof) {
          // expected
        }
        catch(e:Dynamic) {
          trace('Error', 'Error while reading $name stream: $e');
        }
      });
    }

    read('stdout', proc.stdout);
    read('stderr', proc.stderr);

    var code = proc.exitCode();
    if (code != 0) {
      trace('Warning', 'Error while calling the Haxe compiler. It exited with code $code');
      return { success:false, needsFull:needsFull };
    }
    return { success:true, needsFull:needsFull };
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
