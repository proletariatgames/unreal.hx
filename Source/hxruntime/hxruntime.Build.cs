// Copyright 2015 Proletariat Inc.
using System;
using System.IO;
using System.Text;
using System.Diagnostics;
using System.Collections.Generic;
using UnrealBuildTool;

namespace UnrealBuildTool.Rules
{
	public class hxruntime : ModuleRules
	{

		static bool hasRun = false;
		private string ModulePath
		{
			get { return Path.GetDirectoryName( RulesCompiler.GetModuleFilename( this.GetType().Name ) ); }
		}

		private string ThirdPartyPath
		{
			get { return Path.GetFullPath( Path.Combine( ModulePath, "../../ThirdParty/" ) ); }
		}

		private string GameDir
		{
			get { return Path.GetFullPath( Path.Combine( ModulePath, "../../../../" ) ); }
		}

		private string HaxeSourcesPath
		{
			get { return Path.GetFullPath( Path.Combine( GameDir, "Haxe/" ) ); }
		}

		private string InternalHaxeSourcesPath
		{
			get { return Path.GetFullPath( Path.Combine( ModulePath, "../../Haxe/" ) ); }
		}

		public hxruntime(TargetInfo Target)
		{
			Console.WriteLine("\n\n\n=================\nBuild starting here\n" + hasRun + "\n\n");
			PublicIncludePaths.AddRange(
					new string[] {					
					//"Programs/UnrealHeaderTool/Public",
					// ... add other public include paths required here ...
					}
			);

			PrivateIncludePaths.AddRange(
					new string[] {
					// ... add other private include paths required here ...
					}
			);

			PublicDependencyModuleNames.AddRange(
					new string[]
					{
					"Core",
					"CoreUObject",
					"Engine",
					"InputCore",
					"SlateCore",
					// ... add other public dependencies that you statically link with here ...
					}
			);

			if (UEBuildConfiguration.bBuildEditor == true)
			{
				PublicDependencyModuleNames.AddRange(
						new string[] 
						{
						"UnrealEd", 
						}
				);
			}


			DynamicallyLoadedModuleNames.AddRange(
					new string[]
					{
					// ... add any modules that your module loads dynamically here ...
					}
			);

			if (!hasRun)
			{
				hasRun = true;
				CompileAndLoadHaxe(Target);
			}

			// var LuaPath = Path.Combine("..", "Plugins", "ScriptPlugin", "Source", "Lua");				
			// var LuaLibDirectory = Path.Combine(LuaPath, "Lib", Target.Platform.ToString(), "Release");
			// var LuaLibPath = Path.Combine(LuaLibDirectory, "Lua.lib");
			// if (File.Exists(LuaLibPath))
			// {					
			// 	Definitions.Add("WITH_LUA=1");
      //
			// 	// Path to Lua include files
			// 	var IncludePath = Path.GetFullPath(Path.Combine(LuaPath, "Include"));
			// 	PrivateIncludePaths.Add(IncludePath);
      //
			// 	// Lib file
			// 	PublicLibraryPaths.Add(LuaLibDirectory);
			// 	PublicAdditionalLibraries.Add(LuaLibPath);
      //
			// 	Log.TraceVerbose("LUA Integration enabled: {0}", IncludePath);
			// }
			// else
			// {
			// 	Log.TraceVerbose("LUA Integration NOT enabled");
			// }
		}

		public bool CompileAndLoadHaxe(TargetInfo Target)
		{
			bool supported = false;

			// check if haxe compiler / sources are present
			bool hasHaxe = CallHaxe(new string[] {"-version"}, false) == 0;
			Console.WriteLine("has Haxe: " + hasHaxe);

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
				if (toCompile.Count > 0)
				{
					int ret = CompileSources(toCompile.ToArray(), new List<string> { 
						"arguments.hxml",
						"-cp", "../Plugins/ue4hx/Haxe/Static",
						"-cp", "Static",

						"-main", "UnrealInit",

						"-D", "scriptable",
						"-D", "dll_export=",
						"-D", "static_link",
						"-cpp", "../Intermediate/Haxe/Static",
					});
					Console.WriteLine("haxe return:" + ret);
				}

				// PublicLibraryPaths.Add(Path.Combine(GameDir, "Intermediate/Haxe/Static"));
				// PublicAdditionalLibraries.Add("UnrealInit");
				PublicAdditionalLibraries.Add(Path.Combine(GameDir, "Intermediate/Haxe/Static/libUnrealInit.a"));

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
					hx.StartInfo.FileName = "haxe";
					hx.StartInfo.CreateNoWindow = true;
					hx.StartInfo.Arguments = buf.ToString();
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

