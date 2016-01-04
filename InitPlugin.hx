import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
using StringTools;

class InitPlugin {
  static function main() {
    var target = Sys.args()[0];
    if (target == null) {
      target = inferProjectLocation();
    }

    trace("Game location: " + target);
    var gameDir = Path.directory(target);
    var pluginPath = Sys.getCwd();

    updateProject(gameDir, pluginPath, new Path(target).file, true);
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

  public static function updateProject(gameDir:String, pluginPath:String, projectName:String, fromCommandLine=false, ?targetModule:String) {
    gameDir = FileSystem.fullPath(gameDir);
    pluginPath = FileSystem.fullPath(pluginPath);

    trace('Updating game project...');
    updateGameProject(gameDir, projectName);
    trace('Updating game module...');
    updateGameModule(gameDir, pluginPath, fromCommandLine, targetModule);
    inline function checkDir(dir:String) {
      if (!FileSystem.exists(dir))
        FileSystem.createDirectory(dir);
    }
    checkDir('$gameDir/Haxe/Static');
    checkDir('$gameDir/Haxe/Scripts');
    checkDir('$gameDir/Haxe/Externs');
  }

  private static function updateGameModule(gameDir:String, pluginPath:String, fromCommandLine:Bool, targetModule:String)
  {
    var mod = targetModule;
    if (mod == null) {
      mod = getHaxeModule(gameDir);
    }
    // update templates that need to be updated
    function recurse(templatePath:String, toPath:String, alsoDelete:Bool)
    {
      var checkMap = null;

      if (!FileSystem.exists(toPath))
        FileSystem.createDirectory(toPath);
      else if (alsoDelete)
        checkMap = new Map();

      for (file in FileSystem.readDirectory(templatePath))
      {
        // Only copy the module-specific code if
        if ( mod != 'HaxeRuntime' && (file == 'HaxeRuntime.cpp' || file == 'HaxeRuntime.h') )
          continue;
        if (checkMap != null) checkMap[file] = true;
        var curTemplPath = '$templatePath/$file',
            curToPath = '$toPath/$file';
        if (FileSystem.isDirectory(curTemplPath))
        {
          recurse(curTemplPath, curToPath, true);
        } else {
          var shouldCopy = !FileSystem.exists(curToPath) || file.endsWith('.cs');
          var contents = File.getContent(curTemplPath);
          if (mod != 'HaxeRuntime')
            contents = contents.replace('HAXERUNTIME', mod.toUpperCase()).replace('HaxeRuntime', mod);
          if (!shouldCopy && file != 'arguments.hxml')
            shouldCopy = contents != File.getContent(curToPath);

          if (shouldCopy)
            File.saveContent(curToPath, contents);
        }
      }

      if (checkMap != null)
      {
        for (file in FileSystem.readDirectory(toPath))
          if (file != 'Generated' && file != 'Private' && file != 'Public' && !checkMap.exists(file))
            deleteRecursive('$toPath/$file');
      }
    }

    if (mod != null) {
      recurse('$pluginPath/Haxe/Templates/Source/HaxeRuntime', '$gameDir/Source/$mod', false);
      recurse('$pluginPath/Haxe/Templates/Haxe', '$gameDir/Haxe', false);
    }
    // TODO: take this off once we can decide where the plugin dir will be
    if (FileSystem.exists('$gameDir/Source/HaxeRuntime')) {
      deleteRecursive('$gameDir/Source/HaxeRuntime', true);
    }

    handleModuleRules(gameDir, pluginPath, fromCommandLine);
  }

  private static function handleModuleRules(gameDir:String, pluginPath:String, alsoCompile:Bool) {
    var allBuildFiles = [];
    gameDir = gameDir.replace('\\','/');
    pluginPath = pluginPath.replace('\\','/');
    var args = [
      '# use this to build the build tool. if you have made any changes to any .Build.hx files, run this',
      '-cp $pluginPath/Haxe/BuildTool/src',
      '-cp $pluginPath/Haxe/BuildTool',
      '-cp $pluginPath',
      '-net-lib $pluginPath/Haxe/BuildTool/lib/UnrealBuildTool.dll',
      '-cs $gameDir/Intermediate/Haxe/BuildTool',
      'HaxeInit',
      '',
      '-D no-root',
      '-D net_ver=40',
      '-D analyzer',
      '-D real_position',
      '--macro Package.main("$gameDir/Source", [{ name:"HaxeInit", target:"$pluginPath/Source/HaxeInit/HaxeInit.Build.cs" }])'
    ];
    sys.io.File.saveContent('$gameDir/Haxe/build-module-rules.hxml', args.join('\n'));

    if (alsoCompile) {
      // compile the Haxe build plugin
      trace("Building BuildTool...");
      var cmd = Sys.command('haxe',['$gameDir/Haxe/build-module-rules.hxml']);
      if (cmd != 0) throw "Haxe BuildTool compilation failed";
    }
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
