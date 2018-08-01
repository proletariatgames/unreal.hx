import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
using StringTools;

class InitPlugin {
  static inline var LATEST_UE_VER = "4.16";
  static function main() {
    var target = haxe.macro.Compiler.getDefine("GAME_DIR");
    if (target == null) {
      target = inferProjectLocation();
    }

    trace("Game location: " + target);
    var gameDir = Path.directory(target);
    var pluginPath = Sys.getCwd();
    var ver = haxe.macro.Compiler.getDefine("UE_VER");
    if (ver == null) {
      trace('Warning: No UE_VER was set. Assuming latest ($LATEST_UE_VER)).\nPlease specify the version with: `haxe init-plugin.hxml -D UE_VER=4.16');
      ver = LATEST_UE_VER;
    }

    updateProject(gameDir, '$gameDir/Haxe', pluginPath, new Path(target).file, ver, false, true);
    trace("Project update done.");
  }

  static function inferProjectLocation() {
    trace('Inferring project location...');
    var location = '../..';
    for (file in FileSystem.readDirectory(location)) {
      if (file.endsWith('.uproject')) {
        return '../../$file';
      }
    }
    throw 'Cannot find uproject location! Try to specify it as an argument';
  }

  static function getHaxeModule(gameDir:String) {
    var dirs = [];
    for (file in FileSystem.readDirectory('$gameDir/Source')) {
      if (file != 'HaxeRuntime' && FileSystem.isDirectory('$gameDir/Source/$file'))
        dirs.push(file);
    }
    if (dirs.length == 1)
      return dirs[0];
    else
      return null;
  }

  public static function updateProject(gameDir:String, haxeDir:String, pluginPath:String, projectName:String, ueVer:String, isProgram:Bool, fromCommandLine=false, ?targetModule:String) {
    gameDir = FileSystem.fullPath(gameDir);
    pluginPath = FileSystem.fullPath(pluginPath);

    trace('Updating game project...');
    updateGameProject(gameDir, projectName);
    handleModuleRules(gameDir, pluginPath, fromCommandLine, ueVer);
    inline function checkDir(dir:String) {
      if (!FileSystem.exists(dir))
        FileSystem.createDirectory(dir);
    }
    checkDir('$haxeDir/Static');
    checkDir('$haxeDir/Scripts');
    checkDir('$haxeDir/Externs');
  }

  private static function handleModuleRules(gameDir:String, pluginPath:String, alsoCompile:Bool, ueVer:String) {
    if (!FileSystem.exists('$gameDir/Haxe')) {
      FileSystem.createDirectory('$gameDir/Haxe');
    }
    var buildFiles = getBuildFiles(gameDir + '/Source');
    if (buildFiles.files.length == 0) {
      trace('No Build.hx / Target.hx files found. Skipping their compilation');
      return;
    }

    pluginPath = pluginPath.replace('\\','/');
    var args = [
      '# use this to build the build tool. if you have made any changes to any .Build.hx files, run this',
      '-cp $pluginPath/Haxe/BuildTool/src',
      '-cp $pluginPath/Haxe/BuildTool',
      '-cp $pluginPath',
      '-net-lib $pluginPath/Haxe/BuildTool/lib/DotNETUtilities-$ueVer.dll',
      '-net-lib $pluginPath/Haxe/BuildTool/lib/UnrealBuildTool-$ueVer.dll',
      '-cs $gameDir/Intermediate/Haxe/BuildTool',
      'HaxeInit',
      '',
      '-D UE_VER=${ueVer}',
      '-D no-root',
      '-D net_ver=45',
      '-D analyzer',
      '-D real_position',
      '--macro Package.main("$gameDir/Source", [{ name:"Generated", target:"$pluginPath/Source/HaxeInit/Generated.Build.cs" }], ${haxe.Json.stringify(buildFiles)})'
    ];
    sys.io.File.saveContent('$gameDir/Haxe/gen-build-module-rules.hxml', args.join('\n'));

    if (alsoCompile) {
      // compile the Haxe build plugin
      trace("Building BuildTool...");
      var cmd = Sys.command('haxe',['$gameDir/Haxe/gen-build-module-rules.hxml']);
      if (cmd != 0) throw "Haxe BuildTool compilation failed";
    }
  }

  private static function getBuildFiles(srcDir:String):{ files:Array<String>, targetExternal:String } {
    var ret = [],
        dirs = [];
    var targetExternal = null;
    for (dir in FileSystem.readDirectory(srcDir)) {
      if (FileSystem.isDirectory('$srcDir/$dir')) {
        dirs.push(dir);
        for (file in FileSystem.readDirectory('$srcDir/$dir')) {
          if (file.endsWith('.Build.hx')) {
            ret.push('$srcDir/$dir/$file');
          } else if (file.endsWith('.Target.hx')) {
            ret.push('$srcDir/$dir/$file');
          } else if (file == 'HaxeExternalModule.Build.cs') {
            targetExternal = '$srcDir/$dir/$file';
          }
        }
      }
    }
    if (targetExternal == null) {
      if (ret.length > 0) {
        targetExternal = haxe.io.Path.directory(ret[0]) + '/HaxeExternalModule.Build.cs';
      } else {
        if (dirs.length == 0) throw 'No module in source $srcDir was found!';
        targetExternal = '$srcDir/${dirs[0]}/HaxeExternalModule.Build.cs';
      }
    }
    return { files:ret, targetExternal:targetExternal };
  }

  public static function deleteRecursive(path:String, force=false):Bool
  {
    var shouldDelete = true;
    if (!FileSystem.isDirectory(path))
    {
      FileSystem.deleteFile(path);
    } else {
      for (file in FileSystem.readDirectory(path)) {
        if (force || (file != 'Private' && file != 'Public')) {
          shouldDelete = deleteRecursive('$path/$file',force);
        } else {
          shouldDelete = false;
        }
      }
      if (shouldDelete)
        FileSystem.deleteDirectory(path);
    }
    return shouldDelete;
  }

  private static function updateGameProject(gameDir:String, projectName:String)
  {
    var projFile = gameDir + '/$projectName.uproject';
    var props = haxe.Json.parse(File.getContent(projFile));
    var modules:Array<{ Name:String, Type:String, LoadingPhase:String }> = props.Modules;
    // TODO take this off once we support multiple modules
    var allMods = [], shouldChange = false;
    for (module in modules)
    {
      if (module.Name == 'HaxeRuntime')
        shouldChange = true;
      else
        allMods.push(module);
    }

    if (shouldChange) {
      props.Modules = allMods;
      File.saveContent(projFile, haxe.Json.stringify(props));
    }
  }
}
