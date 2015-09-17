package ubuild;
import unrealbuildtool.*;
import haxe.io.Eof;
import sys.FileSystem.*;
import sys.io.Process;
import sys.io.File;
import cs.system.io.Path;
import cs.system.collections.generic.List_1 as Lst;

using ubuild.Helpers;
using StringTools;

/**
  This module will compile Haxe and add the hxcpp runtime to the game.
 **/
@:nativeGen
@:native("UnrealBuildTool.Rules.HaxeRuntime")
class HaxeRuntime extends BaseModuleRules
{
  override private function config(target:TargetInfo, firstRun:Bool)
  {
    // PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "MyProject1" });
    this.PublicDependencyModuleNames.addRange(['Core','CoreUObject','Engine','InputCore','SlateCore']);
    var pvt = Path.GetFullPath('$modulePath/../Private');
    this.PrivateIncludePaths.Add(pvt);
    this.PrivateIncludePaths.Add('$pvt/Generated');
    if (UEBuildConfiguration.bBuildEditor)
      this.PublicDependencyModuleNames.addRange(['UnrealEd']);
    // this.DynamicallyLoadedModuleNames.addRange([]); // modules that are dynamically loaded here


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
    if (firstRun)
    {
      // check if haxe compiler / sources are present
      var hasHaxe = call('haxe', ['-version'], false) == 0;

      if (hasHaxe)
      {
        // create template files
        mkTemplates();
        // bake glue code externs

        var forceCreateExterns = true; //TODO: add logic to check if we're in plugin development mode (env var?)
        var bakeArgs = [
          '# this pass will bake the extern type definitions into glue code',
          '-cp $pluginPath/Haxe/Static',
          '-D use-rtti-doc', // we want the documentation to be persisted
          '',
          '-cpp $gameDir/Haxe/Generated/Externs',
          '--no-output', // don't generate cpp files; just execute our macro
          '--macro ue4hx.internal.ExternBaker.process(["$pluginPath/Haxe/Externs","$gameDir/Haxe/Externs"], $forceCreateExterns)'
        ];
        trace('baking externs');
        var ret = compileSources('bake-externs', null, bakeArgs);

        // compileSource('bake-externs',
        // get all modules that need to be compiled
        var modules = [];
        getModules("Static", modules);
        if (isProduction) getModules("Scripts", modules);
        var curSourcePath = Path.GetFullPath('$modulePath/..');
        // compile static
        if (ret == 0 && modules.length > 0)
        {
          var curStamp:Null<Date> = null;
          if (exists(outputStatic))
            curStamp = stat(outputStatic).mtime;

          trace('compiling Haxe');
          var targetDir = '$gameDir/Intermediate/Haxe/Static';
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
            '-D haxe_runtime_dir=$curSourcePath/Private',
            '-cpp $targetDir',
          ];

          if (!isProduction)
            args = args.concat(['-D scriptable', '-D dll_export=']);
          var ret = compileSources('build-static', modules, args);

          if (ret == 0 && (curStamp == null || stat(outputStatic).mtime.getTime() > curStamp.getTime()))
          {
            // HACK: there seems to be no way to add the .hx files as dependencies
            // for this project. The PrerequisiteItems variable from Action is the one
            // that keeps track of dependencies - and it cannot be set anywhere. Additionally -
            // what it seems to be a bug - UE4 doesn't track the timestamps for the files it is
            // linking against.
            // This leaves little option but to meddle with actual sources' timestamps.
            // It seems that a better least intrusive hack would be to meddle with the
            // output library file timestamp. However, it's not possible to reliably find
            // the output file name at this stage

            var dep = Path.GetFullPath('$modulePath/../Private/HaxeRuntime.cpp');
            // touch the file
            File.saveContent(dep, File.getContent(dep));
          }

          if (ret == 0)
          {
            // get haxe module dependencies
            var deps = File.getContent('$curSourcePath/Private/Generated/Data/modules.txt').split('\n');
            this.PrivateDependencyModuleNames.addRange(deps);
          }
        }
      }
    }

    this.MinFilesUsingPrecompiledHeaderOverride = -1;
    // add the output static linked library
    if (!exists(outputStatic))
    {
      Log.TraceWarning('No Haxe compiled sources found: Compiling without Haxe support');
    } else {
      Log.TraceVerbose('Using Haxe');

      // var hxcppPath = haxelibPath('hxcpp');
      // if (hxcppPath != null)
      //   this.PrivateIncludePaths.Add('$hxcppPath/include');
      this.Definitions.Add('WITH_HAXE=1');
      this.Definitions.Add('HXCPP_EXTERN_CLASS_ATTRIBUTES=');
      this.PublicAdditionalLibraries.Add(outputStatic);
      // FIXME look into why libstdc++ can only be linked with its full path
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

  private function compileSources(name:Null<String>, modules:Array<String>, args:Array<String>)
  {
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
          cmdArgs.push(arg.substr(0,idx));
          cmdArgs.push(arg.substr(idx+1));
          continue;
        }
      }
      cmdArgs.push(arg);
    }
    if (modules != null) {
      var tmpPath = '$gameDir/Intermediate';
      if (!exists(tmpPath)) createDirectory(tmpPath);
      File.saveContent('$tmpPath/files.hxml', modules.join('\n'));
      cmdArgs = ['--cwd', haxeSourcesPath, '$tmpPath/files.hxml'].concat(cmdArgs);
    }

    //TODO: add arguments based on TargetInfo (ios, 32-bit, etc)
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

  private function mkTemplates()
  {
    function recurse(template:String, to:String)
    {
      if (!exists(to))
        createDirectory(to);
      for (file in readDirectory(template))
      {
        var curTempl= '$template/$file',
            curTo= '$to/$file';
        if (isDirectory(curTempl))
        {
          recurse(curTempl, curTo);
        } else {
          var shouldCreate = file != 'arguments.hxml' || !exists(curTo);
          if (shouldCreate)
          {
            File.saveBytes(curTo, File.getBytes(curTempl));
          }
        }
      }
    }

    // var target = '$gameDir/Haxe';
    // if (exists(target))
    recurse('$pluginPath/Haxe/Templates/Haxe', '$gameDir/Haxe');
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
