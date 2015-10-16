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
  private static var VERSION_LEVEL = 1;

  override private function config(target:TargetInfo, firstRun:Bool)
  {
    this.PublicDependencyModuleNames.addRange(['Core','CoreUObject','Engine','InputCore','SlateCore']);
    var base = Path.GetFullPath('$modulePath/..');
    this.PrivateIncludePaths.Add(base + '/Generated/Private');
    this.PublicIncludePaths.Add(base + '/Generated');
    this.PublicIncludePaths.Add(base + '/Generated/Public');
    if (UEBuildConfiguration.bBuildEditor)
      this.PublicDependencyModuleNames.addRange(['UnrealEd']);


    var libName = switch(target.Platform) {
      case WinRT | Win64 | Win32 | XboxOne: // TODO: see if XboxOne follows windows' path names
        'haxeruntime.lib';
      case _:
        'libhaxeruntime.a';
    };
    var outputDir = gameDir + '/Intermediate/Haxe/${target.Platform}';
    var outputStatic = '$outputDir/$libName';
    if (!exists(outputDir)) createDirectory(outputDir);

    var isProduction = false; // TODO: add logic for when making final builds (compile everything as static)
    // try to compile haxe if we have Haxe installed
    this.bUseRTTI = true;
    if (!disabled && firstRun)
    {
      if (Sys.systemName() != 'Windows' && Sys.getEnv('PATH').indexOf('/usr/local/bin') < 0) {
        Sys.putEnv('PATH', Sys.getEnv('PATH') + ":/usr/local/bin");
      }

      // HACK: touch our own .Build.cs file to force Unreal to re-run this build script
      //       sadly there doesn't seem to be any non-hacky way to do this. Unreal seems to have
      //       recently changed how often the build scripts are run - so they don't run if the project
      //       seems updated. This breaks Haxe building, since Unreal has no knowledge of Haxe files
      var buildcs = modulePath;
      cs.system.AppDomain.CurrentDomain.add_ProcessExit(function(_,_) {
        trace('Touching $buildcs');
        var thisTime = cs.system.DateTime.UtcNow;
        // add one second so they don't end up with the exact same timestamp
        thisTime = thisTime.Add( cs.system.TimeSpan.FromSeconds(1) );
        cs.system.io.File.SetLastWriteTimeUtc(buildcs, thisTime);
      });

      // check if haxe compiler / sources are present
      var hasHaxe = call('haxe', ['-version'], false) == 0;

      if (hasHaxe)
      {
        // bake glue code externs

        // Windows paths have '\' which needs to be escaped for macro arguments
        var escapedPluginPath = pluginPath.replace('\\','\\\\');
        var escapedGameDir = gameDir.replace('\\','\\\\');
        var forceCreateExterns = true; //TODO: add logic to check if we're in plugin development mode (env var?)
        var bakeArgs = [
          '# this pass will bake the extern type definitions into glue code',
          '-cp $pluginPath/Haxe/Static',
          '-D use-rtti-doc', // we want the documentation to be persisted
          '-D bake-externs',
          '',
          '-cpp $gameDir/Haxe/Generated/Externs',
          '--no-output', // don't generate cpp files; just execute our macro
          '--macro ue4hx.internal.ExternBaker.process(["$escapedPluginPath/Haxe/Externs","$escapedGameDir/Haxe/Externs"], $forceCreateExterns)'
        ];
        trace('baking externs');
        var ret = compileSources('bake-externs', bakeArgs);

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
          var targetDir = '$gameDir/Intermediate/Haxe/${target.Platform}/Static';
          if (!exists(targetDir)) createDirectory(targetDir);

          var args = [
            'arguments.hxml',
            '-cp $gameDir/Haxe/Generated/Externs',
            '-cp $pluginPath/Haxe/Static',
            '-cp Static',
            '',
            '-main UnrealInit',
            '',
            '-D static_link',
            '-D destination=$outputStatic',
            '-D haxe_runtime_dir=$curSourcePath',
            '-D bake_dir=$gameDir/Haxe/Generated/Externs',
            '-D HXCPP_DLL_EXPORT',
            '-cpp $targetDir/Built',
            '--macro ue4hx.internal.CreateGlue.run([' +modulePaths.join(', ') +'])',
          ];

          switch (target.Platform) {
          case Win32:
            args.push('-D HXCPP_M32');
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
          trace(Sys.getCwd());
          var ret = compileSources(isCrossCompiling ? null : 'build-static', args);

          if (oldEnvs != null)
            setEnvs(oldEnvs);

          if (ret == 0 && isCrossCompiling) {
            // somehow -D destination doesn't do anything when cross compiling
            var hxcppDestination = '$targetDir/Built/libUnrealInit.a';
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

            var dep = Path.GetFullPath('$modulePath/../Generated/HaxeInit.cpp');
            // touch the file
            File.saveContent(dep, File.getContent(dep));
          }

          if (ret != 0)
          {
            throw 'Haxe compilation failed';
          }
        } else {
          throw 'Haxe compilation failed';
        }
      }
    } else if (disabled && firstRun) {
      var gen = try {
        Path.GetFullPath('$modulePath/../Generated');
      } catch(e:Dynamic) {
        null;
      }
      // delete everything in the generated folder
      if (gen != null && exists(gen))
        InitPlugin.deleteRecursive(gen,true);
    }

    // this will disable precompiled headers
    // this.MinFilesUsingPrecompiledHeaderOverride = -1;
    // add the output static linked library
    if (disabled || !exists(outputStatic))
    {
      Log.TraceWarning('No Haxe compiled sources found: Compiling without Haxe support');
    } else {
      Log.TraceVerbose('Using Haxe');

      // get haxe module dependencies
      var targetPath = Path.GetFullPath('$modulePath/../Generated/Data/modules.txt');
      var deps = File.getContent(targetPath).trim().split('\n');
      if (deps.length != 1 || deps[0] != '')
        this.PrivateDependencyModuleNames.addRange(deps);

      // var hxcppPath = haxelibPath('hxcpp');
      // if (hxcppPath != null)
      //   this.PrivateIncludePaths.Add('$hxcppPath/include');
      this.Definitions.Add('WITH_HAXE=1');
      this.Definitions.Add('HXCPP_EXTERN_CLASS_ATTRIBUTES=');
      this.PublicAdditionalLibraries.Add(outputStatic);

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

  private static function setEnvs(envs:Map<String,String>):Map<String,String> {
    var oldEnvs = new Map();
    for (key in envs.keys()) {
      var old = Sys.getEnv(key);
      oldEnvs[key] = old;
      Sys.putEnv(key, envs[key]);
    }
    return oldEnvs;
  }

  private function compileSources(name:Null<String>, args:Array<String>, ?realOutput:String)
  {
    args.push('-D BUILDTOOL_VERSION_LEVEL=$VERSION_LEVEL');
    if (name != null) {
      var hxml = new StringBuf();
      hxml.add('# this file is here for convenience only (e.g. to make your IDE work or to compile without invoking UE4 Build)\n');
      hxml.add('# this is not used by the build pipeline, and is recommended to be ignored by your SCM\n');
      hxml.add('# please change "arguments.hxml" instead\n\n');
      var i = -1;
      for (arg in args)
        hxml.add(arg + '\n');
      File.saveContent('$gameDir/Haxe/$name.hxml', hxml.toString());
    }

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
            Log.TraceInformation(stdout.readLine());
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
}
