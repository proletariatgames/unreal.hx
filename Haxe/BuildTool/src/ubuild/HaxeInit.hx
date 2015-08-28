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
    updateGameProject(proj);
    updateGameModule(proj, false);
  }

  private function updateGameModule(projName:String, alsoDelete:Bool)
  {
    // update templates that need to be updated
    function recurse(templatePath:String, toPath:String, alsoDelete:Bool)
    {
      var checkMap = null;

      if (!exists(toPath))
        createDirectory(toPath);
      else if (alsoDelete)
        checkMap = new Map();

      for (file in readDirectory(templatePath))
      {
        if (checkMap != null) checkMap[file] = true;
        var curTemplPath = '$templatePath/$file',
            curToPath = '$toPath/$file';
        if (isDirectory(curTemplPath))
        {
          recurse(curTemplPath, curToPath, true);
        } else {
          var shouldCopy = !exists(curToPath);
          var contents = File.getContent(curTemplPath);
          if (!shouldCopy)
            shouldCopy = contents != File.getContent(curToPath);

          if (shouldCopy)
            File.saveContent(curToPath, contents);
        }
      }

      if (checkMap != null)
      {
        for (file in readDirectory(toPath))
          if (!checkMap.exists(file))
            deleteRecursive('$toPath/$file');
      }
    }
    recurse('$pluginPath/Haxe/Templates/Source', '$gameDir/Source', false);
  }

  private function deleteRecursive(path:String)
  {
    if (!isDirectory(path))
    {
      deleteFile(path);
    } else {
      for (file in readDirectory(path))
        deleteRecursive('$path/$file');
      deleteDirectory(path);
    }
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
