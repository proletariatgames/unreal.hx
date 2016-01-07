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
class GlueModuleRules extends BaseModuleRules
{
  override private function run(target:TargetInfo, firstRun:Bool)
  {
    var haxeModules = this.getHaxeModules(target);
    if (haxeModules.length != 1) {
      if (haxeModules.length == 0) {
        Log.TraceError('GlueModuleRules was found but no Haxe module was found!');
      } else {
        Log.TraceError('More than one Haxe module was found on this project!');
      }
      Sys.exit(11);
    }

    var targetModule = std.Type.getClassName(std.Type.getClass(this));
    var base = Path.GetFullPath('$modulePath/..');
    this.PrivateIncludePaths.Add(base + '/Generated/Private');
    this.PublicIncludePaths.Add(base + '/Generated');
    this.PublicIncludePaths.Add(base + '/Generated/Shared');
    this.PublicIncludePaths.Add(base + '/Generated/Public');

    var outputDir = gameDir + '/Intermediate/Haxe/${target.Platform}-${target.Configuration}';
    if (UEBuildConfiguration.bBuildEditor) {
      outputDir += '-Editor';
    }
    var modulesPath = Path.GetFullPath('$outputDir/Static/Built/Data/modules.txt');
    var curName = cs.Lib.toNativeType(std.Type.getClass(this)).Name;
    var deps = File.getContent(modulesPath).trim().split('\n');
    if (deps.length != 1 || deps[0] != '') {
      for (dep in deps) {
        if (dep != curName && dep != haxeModules[0]) {
          this.PrivateDependencyModuleNames.Add(dep);
        }
      }
    }
    this.PrivateDependencyModuleNames.Add('HaxeExternalModule');
    this.PrivateDependencyModuleNames.Add(haxeModules[0]);
    // this.CircularlyReferencedDependentModules.Add(haxeModules[0]);
    this.Definitions.Add('WITH_HAXE=1');
  }

  private function getHaxeModules(target:TargetInfo):Array<String> {
    var ret = [];
    for (file in FileSystem.readDirectory('$gameDir/Source')) {
      if (FileSystem.isDirectory('$gameDir/Source/$file')) {
        var type = cs.system.Type.GetType(file);
        if (type == null) {
          type = cs.system.Type.GetType('UnrealBuildTool.$file');
        }
        var myType = type;
        if (myType != null) {
          while (myType != null) {
            if (myType.Name == 'HaxeModuleRules') {
              ret.push(file);
              std.Type.createInstance(cast type,[target]); // just make sure we have built
              break;
            }
            myType = cast std.Type.getSuperClass(cast myType);
          }
        }
      }
    }
    return ret;
  }
}
