import unrealbuildtool.*;
import cs.system.io.Path;
import cs.system.collections.generic.List_1 as Lst;
import sys.FileSystem.*;
import sys.io.File;

using Helpers;
using StringTools;

/**
  This module only setups the HaxeRuntime project correctly as a game module.
  We need HaxeRuntime to be a game module instead of a plugin module since UE4 has some
  different behaviours with plugin code - for example, it does not recompile plugins unless
  the binaries are missing.
 **/
@:nativeGen
@:native("UnrealBuildTool.Rules.HaxeInit")
class HaxeInit extends BaseModuleRules
{
}
