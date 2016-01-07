import unrealbuildtool.*;
import haxe.io.Eof;
import sys.FileSystem;
import sys.FileSystem.*;
import sys.io.Process;
import sys.io.File;
import cs.system.io.Path;
import cs.system.collections.generic.List_1 as Lst;

using Helpers;
using StringTools;

/**
  This module will compile Haxe and add the hxcpp runtime to the game.
 **/
@:nativeGen
class HaxeModuleRules extends BaseModuleRules
{
  private static var disabled:Bool = false;
  private static var VERSION_LEVEL = 3;
  private var config:HaxeModuleConfig;

  private function getConfig():HaxeModuleConfig {
    return {
      disabled: false,
      forceBakeExterns: Sys.getEnv('BAKE_EXTERNS') != null,
      dce: Sys.getEnv('DCE_FULL') != null ? DceFull : (Sys.getEnv('NO_DCE') != null ? DceNo : null),
    };
  }

  override private function run(target:TargetInfo, firstRun:Bool)
  {
    this.config = getConfig();
    if (this.config == null) this.config = {};
    var base = Path.GetFullPath('$modulePath/..');
    if (firstRun) {
      var targetModule = std.Type.getClassName(std.Type.getClass(this));
      if (this.config.glueTargetModule != null) {
        targetModule = this.config.glueTargetModule;
      }
      updateProject(targetModule);

      if (this.config.glueTargetModule != null) {
        if (FileSystem.exists(
        var dir = '$base/Generated';
        if (FileSystem.exists(dir)) {
          for (file in FileSystem.readDirectory(dir)) {
            if (file != 'Private' && file != 'Public') {
              if (FileSystem.isDirectory('$dir/$file')) {
                InitPlugin.deleteRecursive('$dir/$file',true);
              } else {
                FileSystem.deleteFile('$dir/$file');
              }
            }
          }
        }
      }
    }
    this.PublicDependencyModuleNames.addRange(['Core','CoreUObject','Engine','InputCore','SlateCore']);
    this.PrivateIncludePaths.Add(base + '/Generated/Private');
    this.PublicIncludePaths.Add(base + '/Generated');
    this.PublicIncludePaths.Add(base + '/Generated/Shared');
    this.PublicIncludePaths.Add(base + '/Generated/Public');
    if (UEBuildConfiguration.bBuildEditor)
      this.PublicDependencyModuleNames.addRange(['UnrealEd']);

    var libName = switch(target.Platform) {
      case WinRT | Win64 | Win32 | XboxOne: // TODO: see if XboxOne follows windows' path names
        'haxeruntime.lib';
      case _:
        'libhaxeruntime.a';
    };
    var outputDir = gameDir + '/Intermediate/Haxe/${target.Platform}-${target.Configuration}';
    if (UEBuildConfiguration.bBuildEditor) {
      outputDir += '-Editor';
    }

    var outputStatic = '$outputDir/$libName';
    if (!exists(outputDir)) createDirectory(outputDir);

    var isProduction = false; // TODO: add logic for when making final builds (compile everything as static)
    // try to compile haxe if we have Haxe installed
    this.bUseRTTI = true;
    if (firstRun) {
      // HACK: touch our own .Build.cs file to force Unreal to re-run this build script
      //       sadly there doesn't seem to be any non-hacky way to do this. Unreal seems to have
      //       recently changed how often the build scripts are run - so they don't run if the project
      //       seems updated. This breaks Haxe building, since Unreal has no knowledge of Haxe files
      var fileToTouch = modulePath;
      for (file in readDirectory(gameDir)) {
        if (file.endsWith('.uproject')) {
          fileToTouch = '$gameDir/$file';
          break;
        }
      }
      cs.system.AppDomain.CurrentDomain.add_ProcessExit(function(_,_) {
        trace('Touching $fileToTouch');
        var thisTime = cs.system.DateTime.UtcNow;
        // add one second so they don't end up with the exact same timestamp
        thisTime = thisTime.Add( cs.system.TimeSpan.FromSeconds(1) );
        try {
          cs.system.io.File.SetLastWriteTimeUtc(fileToTouch, thisTime);
        } catch(e:Dynamic) {
          if (fileToTouch != modulePath) {
            // the uproject might be write-proteceted because of some
            trace('Touching $fileToTouch failed. Touching $modulePath');
            cs.system.io.File.SetLastWriteTimeUtc(modulePath, thisTime);
          } else {
            cs.Lib.rethrow(e);
          }
        }
      });
    }

    if (!this.config.disabled && firstRun)
    {
      var teverything = timer('Haxe setup (all compilation times included)');
      if (Sys.systemName() != 'Windows' && Sys.getEnv('PATH').indexOf('/usr/local/bin') < 0) {
        Sys.putEnv('PATH', Sys.getEnv('PATH') + ":/usr/local/bin");
      }

      // check if haxe compiler / sources are present
      var hasHaxe = call('haxe', ['-version'], false) == 0;

      if (hasHaxe)
      {
        // bake glue code externs

        // Windows paths have '\' which needs to be escaped for macro arguments
        var escapedPluginPath = pluginPath.replace('\\','\\\\');
        var escapedGameDir = gameDir.replace('\\','\\\\');
        var forceCreateExterns = this.config.forceBakeExterns == null ? Sys.getEnv('BAKE_EXTERNS') != null : this.config.forceBakeExterns;
        var forceDce = this.config.dce == DceFull;
        var forceNoDce = this.config.dce == DceNo;

        if (this.config.dce != null && !forceDce && !forceNoDce && this.config.dce != DceStd) {
          trace('WARNING: Bad config: "${this.config.dce}" is not a valid dce kind (force,no)');
        }
        var externsFolder = UEBuildConfiguration.bBuildEditor ? 'Externs_Editor' : 'Externs';
        var bakeArgs = [
          '# this pass will bake the extern type definitions into glue code',
          '-cp $pluginPath/Haxe/Static',
          '-D use-rtti-doc', // we want the documentation to be persisted
          '-D bake-externs',
          '',
          '-cpp $gameDir/Haxe/Generated/$externsFolder',
          '--no-output', // don't generate cpp files; just execute our macro
          '--macro ue4hx.internal.ExternBaker.process(["$escapedPluginPath/Haxe/Externs","$escapedGameDir/Haxe/Externs"], $forceCreateExterns)'
        ];
        if (UEBuildConfiguration.bBuildEditor) {
          bakeArgs.push('-D WITH_EDITOR');
        }
        trace('baking externs');
        var tbake = timer('bake externs');
        var ret = compileSources(bakeArgs);
        tbake();
        this.createHxml('bake-externs', bakeArgs);

        // compileSource('bake-externs',
        // get all modules that need to be compiled
        var modulePaths = ['$gameDir/Haxe/Static'];
        if (isProduction) modulePaths.push('$gameDir/Haxe/Scripts');
        modulePaths = [ for (path in modulePaths) '"' + path.replace('\\','/') + '"' ]; // windows backslashs
        var curSourcePath = Path.GetFullPath('$modulePath/..');
        // compile static
        if (ret == 0)
        {
          var curStamp:Null<Date> = null;
          if (exists(outputStatic))
            curStamp = stat(outputStatic).mtime;

          trace('compiling Haxe');
          var targetDir = '$outputDir/Static';
          if (!exists(targetDir)) createDirectory(targetDir);

          var cps = [
            'arguments.hxml',
            '-cp $gameDir/Haxe/Generated/$externsFolder',
            '-cp $pluginPath/Haxe/Static',
            '-cp Static',
          ];
          if (this.config.extraStaticClasspaths != null) {
            for (arg in this.config.extraStaticClasspaths) {
              cps.push('-cp $arg');
              modulePaths.push('"' + arg.replace('\\','/') +'"');
            }
          }

          var args = cps.concat([
            '',
            '-main UnrealInit',
            '',
            '-D static_link',
            '-D destination=$outputStatic',
            '-D haxe_runtime_dir=$curSourcePath',
            '-D bake_dir=$gameDir/Haxe/Generated/$externsFolder',
            '-D HXCPP_DLL_EXPORT',
            '-cpp $targetDir/Built',
            '--macro ue4hx.internal.CreateGlue.run([' +modulePaths.join(', ') +'])',
          ]);

          if (this.config.glueTargetModule != null) {
            args.push('-D glue_target_module=${this.config.glueTargetModule}');
          }

          if (UEBuildConfiguration.bBuildEditor) {
            args.push('-D WITH_EDITOR');
          }

          if (forceDce) {
            args.push('-dce full');
          }

          var debugSymbols = target.Configuration != Shipping;
          if (debugSymbols) {
            args.push('-debug');
          } else if (!forceDce && !forceNoDce) {
            args.push('-dce full');
          }

          switch (target.Platform) {
          case Win32:
            args.push('-D HXCPP_M32');
            if (debugSymbols)
              args.push('-D HXCPP_DEBUG_LINK');
          case Win64:
            args.push('-D HXCPP_M64');
          case WinRT:
            args.push('-D HXCPP_M64');
            args.push('-D winrt');
          case _:
            args.push('-D HXCPP_M64');
          }

          // set correct ABI
          switch (target.Platform) {
          case WinRT | Win64 | Win32 | XboxOne: // TODO: see if XboxOne follows windows' path names
            args.push('-D ABI=-MD');
          case _:
          }

          // if (!isProduction)
          //   args = args.concat(['-D scriptable', '-D dll_export=']);

          var isCrossCompiling = false;
          var extraArgs = null,
              oldEnvs = null;
          switch(target.Platform) {
          case Linux if (Sys.systemName() != "Linux"):
            // cross compiling
            isCrossCompiling = true;
            var crossPath = Sys.getEnv("LINUX_ROOT");
            if (crossPath != null) {
              Log.TraceInformation('Cross compiling using $crossPath');
              extraArgs = [
                '-D toolchain=linux',
                '-D linux',
                '-D HXCPP_CLANG',
                '-D xlinux_compile',
                '-D magiclibs',
                '-D HXCPP_VERBOSE'
              ];
              oldEnvs = setEnvs([
                'PATH' => Sys.getEnv("PATH") + (Sys.systemName() == "Windows" ? ";" : ":") + crossPath + '/bin',
                'CXX' => 'clang++ --sysroot "$crossPath" -target x86_64-unknown-linux-gnu',
                'CC' => 'clang --sysroot "$crossPath" -target x86_64-unknown-linux-gnu',
                'HXCPP_AR' => 'x86_64-unknown-linux-gnu-ar',
                'HXCPP_AS' => 'x86_64-unknown-linux-gnu-as',
                'HXCPP_LD' => 'x86_64-unknown-linux-gnu-ld',
                'HXCPP_RANLIB' => 'x86_64-unknown-linux-gnu-ranlib',
                'HXCPP_STRIP' => 'x86_64-unknown-linux-gnu-strip'
              ]);
            } else {
              Log.TraceWarning('Cross-compilation was detected but no LINUX_ROOT environment variable was set');
            }
          case _:
          }

          if (extraArgs != null)
            args = args.concat(extraArgs);
          if (this.config.extraCompileArgs != null)
            args = args.concat(this.config.extraCompileArgs);

          if (Sys.getEnv('HAXE_COMPILATION_SERVER') != null) {
            args.push('-D IN_COMPILATION_SERVER');
          } else {
            args.push('# be sure to add -D IN_COMPILATION_SERVER if compiling with the compilation server');
          }

          var thaxe = timer('Haxe compilation');
          var ret = compileSources(args);
          thaxe();
          if (!isCrossCompiling) {
            this.createHxml('build-static', args);
            var complArgs = ['--cwd $gameDir/Haxe', '--no-output'].concat(args);
            this.createHxml('compl-static', complArgs.filter(function(v) return !v.startsWith('--macro')));
          }

          if (oldEnvs != null)
            setEnvs(oldEnvs);

          if (ret == 0 && isCrossCompiling) {
            // somehow -D destination doesn't do anything when cross compiling
            // if (
            var hxcppDestination = '$targetDir/Built/libUnrealInit';
            if (debugSymbols)
              hxcppDestination += '-debug.a';
            else
              hxcppDestination += '.a';

            var shouldCopy =
              !exists(outputStatic) ||
              (exists(hxcppDestination) &&
               stat(hxcppDestination).mtime.getTime() > stat(outputStatic).mtime.getTime());
            if (shouldCopy) {
              File.saveBytes(outputStatic, File.getBytes(hxcppDestination));
            }
          }
          if (ret == 0 && (curStamp == null || stat(outputStatic).mtime.getTime() > curStamp.getTime()))
          {
            // HACK: there seems to be no way to add the .hx files as dependencies
            //       for this project. The PrerequisiteItems variable from Action is the one
            //       that keeps track of dependencies - and it cannot be set anywhere. Additionally -
            //       what it seems to be a bug - UE4 doesn't track the timestamps for the files it is
            //       linking against.
            //       This leaves little option but to meddle with actual sources' timestamps.
            //       It seems that a better least intrusive hack would be to meddle with the
            //       output library file timestamp. However, it's not possible to reliably find
            //       the output file name at this stage

            // var dep = Path.GetFullPath('$modulePath/../Generated/HaxeInit.cpp');
            // touch the file
            // File.saveContent(dep, File.getContent(dep));
          }

          if (ret != 0)
          {
            Log.TraceError('Haxe compilation failed');
            Sys.exit(10);
          }
        } else {
          Log.TraceError('Haxe compilation failed');
          Sys.exit(10);
        }
      }
      teverything();
    } else if (this.config.disabled && firstRun) {
      var gen = try {
        Path.GetFullPath('$modulePath/../Generated');
      } catch(e:Dynamic) {
        null;
      }
      // delete everything in the generated folder
      if (gen != null && exists(gen))
        InitPlugin.deleteRecursive(gen,true);
    }

    if (this.config.glueTargetModule != null) {
      this.PrivateDependencyModuleNames.Add(this.config.glueTargetModule);
      this.CircularlyReferencedDependentModules.Add(this.config.glueTargetModule);
    }

    // add the output static linked library
    if (this.config.disabled || !exists(outputStatic))
    {
      Log.TraceWarning('No Haxe compiled sources found: Compiling without Haxe support');
    } else {
      Log.TraceVerbose('Using Haxe');

      // get haxe module dependencies
      var targetPath = Path.GetFullPath('$outputDir/Static/Built/Data/modules.txt');
      var curName = cs.Lib.toNativeType(std.Type.getClass(this)).Name;
      var deps = File.getContent(targetPath).trim().split('\n');
      if (deps.length != 1 || deps[0] != '') {
        for (dep in deps) {
          if (dep != this.config.glueTargetModule && dep != curName) {
            this.PrivateDependencyModuleNames.Add(dep);
          }
        }
      }

      // var hxcppPath = haxelibPath('hxcpp');
      // if (hxcppPath != null)
      //   this.PrivateIncludePaths.Add('$hxcppPath/include');
      this.Definitions.Add('WITH_HAXE=1');
      this.Definitions.Add('HXCPP_EXTERN_CLASS_ATTRIBUTES=');
      // this.PublicAdditionalLibraries.Add(outputStatic);
      if (this.config.glueTargetModule == null) {
      this.PrivateDependencyModuleNames.Add('HaxeExternalModule');
      }

      // FIXME look into why libstdc++ can only be linked with its full path
      if (FileSystem.exists('/usr/lib/libstdc++.dylib'))
        this.PublicAdditionalLibraries.Add('/usr/lib/libstdc++.dylib');

      switch(target.Platform)
      {
        case WinRT | Win64 | Win32:
          this.Definitions.Add('HX_WINDOWS');
          if (target.Platform == WinRT)
            this.Definitions.Add('HX_WINRT');
        case Mac:
          this.Definitions.Add('HX_MACOS');
        case Linux:
          this.Definitions.Add('HX_LINUX');
        case Android:
          this.Definitions.Add('HX_ANDROID');
        case IOS:
          this.Definitions.Add('IPHONE');
          this.Definitions.Add('IPHONEOS');
        case HTML5:
          this.Definitions.Add('EMSCRIPTEN');
        case _:
        // XboxOne | PS4 | IOS | HTML5
      }
    }
  }

  /**
    Adds the HaxeRuntime module to the game project if it isn't there, and updates
    the template files
   **/
  private function updateProject(targetModule:String)
  {
    var proj = getProjectName();
    if (proj == null) throw 'no uproject found!';
    InitPlugin.updateProject(this.gameDir, this.pluginPath, proj, false, targetModule);
  }

  private static function setEnvs(envs:Map<String,String>):Map<String,String> {
    var oldEnvs = new Map();
    for (key in envs.keys()) {
      var old = Sys.getEnv(key);
      oldEnvs[key] = old;
      Sys.putEnv(key, envs[key]);
    }
    return oldEnvs;
  }

  private function createHxml(name:String, args:Array<String>) {
    var hxml = new StringBuf();
    hxml.add('# this file is here for convenience only (e.g. to make your IDE work or to compile without invoking UE4 Build)\n');
    hxml.add('# this is not used by the build pipeline, and is recommended to be ignored by your SCM\n');
    hxml.add('# please change "arguments.hxml" instead\n\n');
    var i = -1;
    for (arg in args)
      hxml.add(arg + '\n');
    File.saveContent('$gameDir/Haxe/gen-$name.hxml', hxml.toString());
  }

  private function compileSources(args:Array<String>, ?realOutput:String)
  {
    args.push('-D BUILDTOOL_VERSION_LEVEL=$VERSION_LEVEL');

    var cmdArgs = [];
    for (arg in args) {
      if (arg == '' || arg.charCodeAt(0) == '#'.code) continue;

      if (arg.charCodeAt(0) == '-'.code) {
        var idx = arg.indexOf(' ');
        if (idx > 0) {
          var cmd = arg.substr(0,idx);
          cmdArgs.push(cmd);
          if (cmd == '-cpp' && realOutput != null)
            cmdArgs.push(realOutput);
          else
            cmdArgs.push(arg.substr(idx+1));
          continue;
        }
      }
      cmdArgs.push(arg);
    }
    cmdArgs = ['--cwd', haxeSourcesPath].concat(cmdArgs);
    if (!this.config.disableTimers) {
      cmdArgs.push('--times');
      cmdArgs.push('-D');
      cmdArgs.push('macro_times');
    }

    return call('haxe', cmdArgs, true);
  }

  private function getModules(name:String, modules:Array<String>)
  {
    function recurse(path:String, pack:String)
    {
      if (pack == 'ue4hx.' || pack == 'unreal.') return;
      for (file in readDirectory(path))
      {
        if (file.endsWith('.hx'))
          modules.push(pack + file.substr(0,-3));
        else if (isDirectory('$path/$file'))
          recurse('$path/$file', pack + file + '.');
      }
    }

    var game = '$gameDir/Haxe/$name';
    if (exists(game)) recurse(game, '');
    var templ = '$pluginPath/Haxe/$name';
    if (exists(templ)) recurse(templ, '');
  }

  private function call(program:String, args:Array<String>, showErrors:Bool)
  {
    Log.TraceInformation('$program ${args.join(' ')}');
    var proc:Process = null;
    try
    {
      proc = new Process(program, args);
      var t = new cs.system.threading.Thread(function() {
        var stdout = proc.stdout;
        try
        {
          while(true)
          {
            // !!HACK!! Unreal seems to fail for no reason if the log line is too long on OSX
            Log.TraceInformation(stdout.readLine().substr(0,1024));
          }
        }
        catch(e:Eof) {}
      });
      t.Start();

      var stderr = proc.stderr;
      try
      {
        while(true)
        {
          var ln = stderr.readLine();
          if (ln.indexOf(': Warning :') >= 0)
          {
            Log.TraceWarning('HaxeCompiler: $ln');
          } else if (showErrors) {
            Log.TraceError('HaxeCompiler: $ln');
          } else {
            Log.TraceInformation('HaxeCompiler: $ln');
          }
        }
      }
      catch(e:Eof) {}

      t.Join();
      var code = proc.exitCode();
      proc.close();
      return code;
    }
    catch(e:Dynamic)
    {
      Log.TraceError('ERROR: failed to launch `haxe ${args.join(' ')}` : $e');
      if (proc != null)
      {
        try proc.close() catch(e:Dynamic) {};
      }
      return -1;
    }
  }

  public function haxelibPath(name:String):String
  {
    try
    {
      var haxelib = new sys.io.Process('haxelib',['path', name]);
      var found = null;
      if (haxelib.exitCode() == 0)
      {
        for (ln in haxelib.stdout.readAll().toString().split('\n'))
        {
          if (exists(ln))
          {
            found = ln;
            break;
          }
        }
        if (found == null)
          Log.TraceError('Cannot find a valid path for haxelib path $name');
      } else {
        Log.TraceError('Error while calling haxelib path $name: ${haxelib.stderr.readAll()}');
      }
      haxelib.close();
      return found;
    }
    catch(e:Dynamic)
    {
      Log.TraceError('Error while calling haxelib path $name: $e');
      return null;
    }
  }

  private function timer(name:String):Void->Void {
    if (this.config.disableTimers)
      return function() {};
    var sw = new cs.system.diagnostics.Stopwatch();
    sw.Start();
    return function() {
      sw.Stop();
      Log.TraceInformation(' -> $name executed in ${sw.Elapsed}');
    }
  }
}
