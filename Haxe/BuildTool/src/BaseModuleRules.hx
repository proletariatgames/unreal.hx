import unrealbuildtool.*;
import cs.system.io.Path;
import cs.system.collections.generic.List_1 as Lst;
import sys.FileSystem.*;
import sys.FileSystem;

using Helpers;
using StringTools;

/**
  Adds some helper functions to ModuleRules - like getting the game directory and making sure the code only runs once
 **/
@:nativeGen
class BaseModuleRules extends ModuleRules
{
  // we need this here since the constructor is called more
  // than once per compilation - but we want to compile
  // the Haxe code exactly once
  static var firstRunMap = new Map();

  var modulePath:String;
  var pluginPath:String;
  var thirdPartyPath:String;
  var gameDir:String;
  var haxeDir:String;
  var internalHaxeSourcesPath:String;
  var target:TargetInfo;

  public function new(target:TargetInfo)
  {
    super();

    var curName = cs.Lib.toNativeType(std.Type.getClass(this)).Name;
    var firstRun = !firstRunMap.exists(curName);

    var allGames:Array<Dynamic> = cs.Lib.array(UProjectInfo.FilterGameProjects(false, null).ToArray())
                                              .map(function(x) return x.Folder);
    if (allGames.length > 1) {
      trace("AllGameFolders is returning more than one: ",allGames);
    }
    modulePath = RulesCompiler.GetModuleFilename(curName);
    var haxeInitPath = RulesCompiler.GetModuleFilename("HaxeInit");
    pluginPath = Path.GetFullPath('$haxeInitPath/../../..');
    thirdPartyPath = Path.GetFullPath(haxeInitPath + "/../../ThirdParty");
    gameDir = allGames[0].ToString();
    if (gameDir == null)
      gameDir = Path.GetFullPath(haxeInitPath + "/../../../..");
    internalHaxeSourcesPath = Path.GetFullPath(haxeInitPath + "/../../Haxe");

    if (FileSystem.exists(modulePath.substr(0,-2) + 'hx')) {
      if (FileSystem.stat(modulePath).mtime.getTime() < FileSystem.stat(modulePath.substr(0,-2) + 'hx').mtime.getTime()) {
        Log.TraceError('Your Build.cs file is outdated. Please run `haxe init-plugin.hxml` in the unreal.hx plugin directory');
        Sys.exit(11);
      }
    }

    haxeDir = getHaxeDir();
    this.target = target;
    run(target, firstRun);
    firstRunMap[curName] = false;
  }

  private function getHaxeDir() {
    return Path.GetFullPath('$gameDir/Haxe');
  }

  private function run(target:TargetInfo, firstRun:Bool)
  {
    throw 'Override me';
  }

  private function getProjectName()
  {
    for (file in readDirectory(gameDir))
    {
      if (file.endsWith('.uproject'))
      {
        return file.substr(0, file.length - '.uproject'.length);
      }
    }

    trace('ERROR: no uproject was found on $gameDir');
    return null;
  }
}
