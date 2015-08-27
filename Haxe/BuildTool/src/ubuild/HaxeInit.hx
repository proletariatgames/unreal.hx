package ubuild;
import unrealbuildtool.*;
import cs.system.io.Path;
import cs.system.collections.generic.List_1 as Lst;
import sys.FileSystem.*;
import sys.io.File;

using ubuild.Helpers;
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
  override private function config(firstRun:Bool)
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
    updateGameProject(proj);
    updateGameModule(proj);
  }

  private function updateGameModule(projName:String)
  {
    // update templates that need to be updated
    function recurse(templatePath:String, toPath:String)
    {
      if (!exists(toPath))
        createDirectory(toPath);
      for (file in readDirectory(templatePath))
      {
        var curTemplPath = '$templatePath/$file',
            curToPath = '$toPath/$file';
        if (isDirectory(curTemplPath))
        {
          recurse(curTemplPath, curToPath);
        } else {
          if (!exists(curToPath) || File.getContent(curTemplPath) != File.getContent(curToPath))
          {
            trace('copying',curToPath);
            File.copy(curTemplPath, curToPath);
          }
        }
      }
    }
    recurse('$pluginPath/Haxe/Templates/Source', '$gameDir/Source');
  }

  private function updateGameProject(projName:String)
  {
    var projFile = this.gameDir + '/$projName.uproject';
    var props = haxe.Json.parse(File.getContent(projFile));
    var modules:Array<{ Name:String, Type:String, LoadingPhase:String }> = props.Modules;
    for (module in modules)
    {
      if (module.Name == 'HaxeRuntime')
        return; //already there
    }

    trace('adding');
    modules.push({ Name:'HaxeRuntime', Type:'Runtime', LoadingPhase:'Default' });
    File.saveContent(projFile, haxe.Json.stringify(props));
  }
}
