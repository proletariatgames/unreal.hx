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
  override private function config(target:TargetInfo, firstRun:Bool)
  {
    this.PublicDependencyModuleNames.addRange(['Core','CoreUObject','Engine','InputCore','SlateCore']);
    if (firstRun) updateProject();
  }

  /**
    Adds the HaxeRuntime module to the game project if it isn't there, and updates
    the template files
   **/
  private function updateProject()
  {
    var proj = getProjectName();
    if (proj == null) return; // error state: do not fail; UE4 doesn't like exceptions on build scripts
    InitPlugin.updateProject(this.gameDir, this.pluginPath, proj);
  }
}
