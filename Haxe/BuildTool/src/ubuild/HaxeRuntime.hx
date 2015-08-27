package ubuild;
import unrealbuildtool.*;
import cs.system.io.Path;
import cs.system.collections.generic.List_1 as Lst;

using ubuild.Helpers;

/**
  This module will compile Haxe and add the hxcpp runtime to the game.
 **/
@:nativeGen
@:native("UnrealBuildTool.Rules.HaxeRuntime")
class HaxeRuntime extends BaseModuleRules
{
  override private function config(firstRun:Bool)
  {
    this.PublicIncludePaths.addRange(['$modulePath/Public']);
    this.PrivateIncludePaths.addRange(['$modulePath/Private']);
    this.PublicDependencyModuleNames.addRange(['Core','CoreUObject','Engine','InputCore','SlateCore']);
    if (UEBuildConfiguration.bBuildEditor)
      this.PublicDependencyModuleNames.addRange(['UnrealEd']);
    // this.DynamicallyLoadedModuleNames.addRange([]); // modules that are dynamically loaded here
  }
}

/*
// Copyright 2015 Proletariat Inc.
using System;
using System.IO;
using System.Text;
using System.Diagnostics;
using System.Collections.Generic;
using UnrealBuildTool;

namespace UnrealBuildTool.Rules
{
	public class HaxeRuntime : ModuleRules
	{

		public HaxeRuntime(TargetInfo Target)
		{
			if (UEBuildConfiguration.bBuildEditor == true)
			{
				PublicDependencyModuleNames.AddRange(
						new string[]
						{
						"UnrealEd",
						}
				);
			}

			CompileAndLoadHaxe(Target, !hasRun);
			// we need to set hasRun since this code runs more than once per build
			hasRun = true;
		}

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
