// Copyright 2015 Proletariat Inc.
using System;
using System.IO;
using UnrealBuildTool;

namespace UnrealBuildTool.Rules
{
	public class hxruntime : ModuleRules
	{
		// protected string ModulePath
		// {
		// 	get {
		// 	}
		// }

		public hxruntime(TargetInfo Target)
		{
			Console.WriteLine("\n\n\n=================\nBuild starting here\n");
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
	}
}

