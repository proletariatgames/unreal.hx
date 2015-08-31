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
        // get all modules that need to be compiled
        var modules = [];
        getModules("Static", modules);
        if (isProduction) getModules("Scripts", modules);
        // compile static
        if (modules.length > 0)
        {
          var curStamp:Null<Date> = null;
          if (exists(outputStatic))
            curStamp = stat(outputStatic).mtime;

          trace('compiling Haxe');
          var targetDir = '$gameDir/Intermediate/Haxe/Static';
          var args = [
            'arguments.hxml',
            '-cp', '$pluginPath/Haxe/Static',
            '-cp', 'Static',

            '-main', 'UnrealInit',

            '-D', 'no-compilation',
            '-D', 'static_link',
            '-D', 'destination=$outputStatic',
            '-cpp', targetDir,

            '--macro', 'ue4hx.internal.Build.build("$targetDir/uobjects.txt")'
          ];

          if (!isProduction)
            args = args.concat(['-D', 'scriptable', '-D', 'dll_export=']);
          var ret = compileSources(modules, args);

          if (ret == 0)
          {
            var uobjects = new Map();
            // move the uobjects
            for (uobject in File.getContent(targetDir + '/uobjects.txt').split('\n'))
            {
              if (uobject == '') continue;
              uobjects['src/$uobject.cpp'] = true;
              var sourceFile = '$targetDir/src/$uobject.cpp';
              var content = "#include <HaxeRuntime.h>\n" + File.getContent(sourceFile);
              var target = fullPath('$modulePath/../Generated/$uobject.cpp');
              if (!exists(target))
              {
                createDirectory( haxe.io.Path.directory(target) );
                File.saveContent(target, content);
              } else if (content != File.getContent(target)) {
                File.saveContent(target, content);
              }
              deleteFile(sourceFile);
            }

            // change the build xml
            var xml = Xml.parse( File.getContent('$targetDir/Build.xml') ).firstElement();
            for (parent in xml.elements())
            {
              if (parent.nodeType == Element && parent.nodeName == 'files')
              {
                var toRemove = [];
                for (elt in parent)
                {
                  if (elt.nodeType == Element
                      && elt.nodeName == 'file'
                      && elt.get('name') != null
                      && uobjects.exists(elt.get('name'))
                     )
                  {
                    toRemove.push(elt);
                  }
                }
                for (file in toRemove) parent.removeChild(file);
              }
            }
            trace('here ok');
            trace(xml);
            File.saveContent('$targetDir/Build.xml', xml.toString());

            // build it
            var opts = [ for (opt in File.getContent(targetDir + '/Options.txt').split('\n')) '-D' + opt ];
            var last = Sys.getCwd();
            Sys.setCwd(targetDir);
            ret = call('haxelib',['run','hxcpp','Build.xml'].concat(opts), true);
            Sys.setCwd(last);
          }
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

            var dep = Path.GetFullPath('$modulePath/../HaxeRuntime.h');
            // touch the file
            File.saveContent(dep, File.getContent(dep));
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

      var hxcppPath = haxelibPath('hxcpp');
      if (hxcppPath != null)
        this.PrivateIncludePaths.Add('$hxcppPath/include');
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

  private function compileSources(modules:Array<String>, args:Array<String>)
  {
    var tmpPath = '$gameDir/Intermediate';
    if (!exists(tmpPath)) createDirectory(tmpPath);
    File.saveContent('$tmpPath/files.hxml', modules.join('\n'));
    args = ['--cwd', haxeSourcesPath, '$tmpPath/files.hxml'].concat(args);

    //TODO: add arguments based on TargetInfo (ios, 32-bit, etc)

    return call('haxe', args, true);
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

/*
		public bool CompileAndLoadHaxe(TargetInfo Target, bool compileHaxe)
		{
			bool supported = false;

			// check if haxe compiler / sources are present
			bool hasHaxe = CallHaxe(new string[] {"-version"}, false) == 0;

			if (hasHaxe)
			{
				// create template files
				CopyTemplates(Path.Combine(InternalHaxeSourcesPath, "Templates"), HaxeSourcesPath);
				// compile hxcpp static
				bool shouldRecompile = false;
				List<string> toCompile = new List<string>();

				CheckCompilation(HaxeSourcesPath, "Static", toCompile, ref shouldRecompile);
				CheckCompilation(InternalHaxeSourcesPath, "Static", toCompile, ref shouldRecompile);

				// for now, we're ignoring shouldRecompile because we may edit dependencies that aren't directly in
				// the directories followed. Maybe in the future we might look into all source paths (TODO)
				string curLibName = "libhaxeruntime.a"; //TODO: add prefixes and extensions according to platform
				string curOutput = Path.Combine(GameDir, "Intermediate/Haxe/Static/" + curLibName);
				if (toCompile.Count > 0 && compileHaxe)
				{
					Console.WriteLine("Compiling Haxe");
					DateTime? lastDate = null;
					if (File.Exists(curOutput))
					{
						lastDate = File.GetLastWriteTimeUtc(curOutput);
					}
					int ret = CompileSources(toCompile.ToArray(), new List<string> {
						"arguments.hxml",
						"-cp", "../Plugins/UE4Haxe/Haxe/Static",
						"-cp", "Static",

						"-main", "UnrealInit",

						"-D", "scriptable",
						"-D", "dll_export=",
						"-D", "static_link",
						"-D", "destination=" + curLibName,
						"-cpp", "../Intermediate/Haxe/Static",
					});
					Console.WriteLine("Haxe return code: " + ret);

					if (ret == 0 && lastDate != null && File.GetLastWriteTimeUtc(curOutput) > lastDate)
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
						//
						// Currently, Unreal doesn't support automatic recompilation of plugins
						// (see https://forums.unrealengine.com/showthread.php?56191-Plugin-development-and-hot-reload-not-working)
						// So any Static Haxe files must be recompiled by accessing
						// Window->Developer Tools->Modules and recompiling HaxeRuntime

						string targetPath = Path.Combine(ModulePath, "Private", "HaxeRuntime.cpp"); // use a well known source path
						File.SetLastWriteTimeUtc(targetPath, DateTime.UtcNow);
					}
				}
				PublicAdditionalLibraries.Add(curOutput);

				// PublicAdditionalLibraries.Add("stdc++");
				// FIXME look into why libstdc++ can only be linked with its full path
				PublicAdditionalLibraries.Add("/usr/lib/libstdc++.dylib");

				// TODO: compile hxcpp script
				// shouldRecompile = false;
				// toCompile = new List<string>();

				// CheckCompilation(HaxeSourcesPath, "Scripts", toCompile, ref shouldRecompile);
			}
			// if no haxe check if there is an already built output
			// load static library

			return supported;
		}

		private void CheckCompilation(string sourcesDir, string passName, List<string> toCompile, ref bool shouldRecompile)
		{
			DateTime lastCompilation = new DateTime(0L);

			sourcesDir = Path.Combine(sourcesDir, passName);
			string pass = Path.Combine(GameDir, "Intermediate/Haxe/" + passName);
			if (File.Exists(Path.Combine(pass, "Build.xml")))
			{
				lastCompilation = File.GetLastWriteTimeUtc(Path.Combine(pass, "Build.xml"));
			}

			CheckTimestampsRecurse(lastCompilation, sourcesDir, "", toCompile, ref shouldRecompile);
		}

		private void CheckTimestampsRecurse(DateTime baseTime, string dirPath, string pack, List<string> toCompile, ref bool shouldRecompile)
		{
			if (Directory.Exists(dirPath))
			{
				string[] paths = Directory.GetFileSystemEntries(dirPath);
				foreach (string path in paths)
				{
					string name = Path.GetFileName(path);
					if (path.EndsWith(".hx"))
					{
						if (File.GetLastWriteTimeUtc(path) > baseTime)
							shouldRecompile = true;
						toCompile.Add(pack + name.Substring(0, name.Length - 3));
					} else if (Directory.Exists(path)) {
						string newPack = pack + name + ".";
						CheckTimestampsRecurse(baseTime, path, newPack, toCompile, ref shouldRecompile);
					}
				}
			}
		}

		private void CopyTemplates(string from, string to)
		{
			if (!Directory.Exists(to))
				Directory.CreateDirectory(to);

			if (Directory.Exists(from))
			{
				foreach (string path in Directory.GetFileSystemEntries(from))
				{
					string newPath = Path.Combine(to, Path.GetFileName(path));
					if (Directory.Exists(path))
					{
						CopyTemplates(path, newPath);
					} else if (!File.Exists(newPath)) {
						File.Copy(path,newPath);
					}
				}
			}
		}

		public int CompileSources(string[] sources, List<string> args)
		{
			// create a temp file to work around file argument limitation
			string tmpPath = Path.Combine(GameDir, "Intermediate");
			if (!Directory.Exists(tmpPath))
				Directory.CreateDirectory(tmpPath);
			File.WriteAllText( Path.Combine(tmpPath, "files.hxml"), string.Join("\n", sources) );
			args.Insert(0, HaxeSourcesPath);
			args.Insert(0, "--cwd");
			args.Add(Path.Combine(tmpPath, "files.hxml"));

			// TODO: add arguments based on TargetInfo (ios,32-bit,etc)

			return CallHaxe(args.ToArray(), true);
		}

		public int CallHaxe(string[] args, bool showErrors)
		{
			try
			{
				using (Process hx = new Process())
				{
					StringBuilder buf = new StringBuilder();
					bool first = true;
					foreach(string arg in args)
					{
						if (first) first = false; else buf.Append(" ");
						buf.Append("\"");
						buf.Append(arg.Replace("\\", "\\\\").Replace("\"", "\\\""));
						buf.Append("\"");
					}
					string hxargs = buf.ToString();
					Console.WriteLine("haxe " + hxargs);

					hx.StartInfo.FileName = "haxe";
					hx.StartInfo.CreateNoWindow = true;
					hx.StartInfo.Arguments = hxargs;
					hx.StartInfo.RedirectStandardError = true;
					hx.StartInfo.UseShellExecute = false;
					hx.Start();
					using (StreamReader reader = hx.StandardError)
					{
						while (reader.Peek() >= 0)
						{
							string line = reader.ReadLine();
							if (line.Contains(": Warning :"))
							{
								Log.TraceWarning("HaxeCompiler: " + line);
							} else if(showErrors) {
								Log.TraceError("HaxeCompiler: " + line);
							} else {
								Log.TraceInformation("HaxeCompiler: " + line);
							}
						}
					}

					hx.WaitForExit();
					return hx.ExitCode;
				}
			}
			catch (Exception e)
			{
				Log.TraceError("ERROR: Failed to launch `haxe " + string.Join(" ", args) + "`: " + e);
				return -1;
			}
		}
	}
}
*/
