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
    // compile the Haxe build plugin
    trace("Building BuildTool...");
    var cmd = Sys.command('haxe',['--cwd','$pluginPath/Haxe/BuildTool','build.hxml']);
    if (cmd != 0) throw "Haxe BuildTool compilation failed";

    updateProject(gameDir, pluginPath, new Path(target).file);

    trace("Project update done. Don't forget to add the 'HaxeRuntime' project to your .Target.cs file!");
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

  public static function updateProject(gameDir:String, pluginPath:String, projectName:String)
  {
    trace('Updating game project...');
    updateGameProject(gameDir, projectName);
    trace('Updating game module...');
    updateGameModule(gameDir, pluginPath);
  }

  private static function updateGameModule(gameDir:String, pluginPath:String)
  {
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
        if (checkMap != null) checkMap[file] = true;
        var curTemplPath = '$templatePath/$file',
            curToPath = '$toPath/$file';
        if (FileSystem.isDirectory(curTemplPath))
        {
          recurse(curTemplPath, curToPath, true);
        } else {
          var shouldCopy = !FileSystem.exists(curToPath) || file.endsWith('.cs');
          var contents = File.getContent(curTemplPath);
          if (!shouldCopy)
            shouldCopy = contents != File.getContent(curToPath);

          if (shouldCopy)
            File.saveContent(curToPath, contents);
        }
      }

      if (checkMap != null)
      {
        for (file in FileSystem.readDirectory(toPath))
          if (file != 'Generated' && !checkMap.exists(file))
            deleteRecursive('$toPath/$file');
      }
    }
    recurse('$pluginPath/Haxe/Templates/Source', '$gameDir/Source', false);
  }

  private static function deleteRecursive(path:String)
  {
    if (!FileSystem.isDirectory(path))
    {
      FileSystem.deleteFile(path);
    } else {
      for (file in FileSystem.readDirectory(path)) {
        if (file != 'Generated')
          deleteRecursive('$path/$file');
      }
      FileSystem.deleteDirectory(path);
    }
  }

  private static function updateGameProject(gameDir:String, projectName:String)
  {
    var projFile = gameDir + '/$projectName.uproject';
    var props = haxe.Json.parse(File.getContent(projFile));
    var modules:Array<{ Name:String, Type:String, LoadingPhase:String }> = props.Modules;
    for (module in modules)
    {
      if (module.Name == 'HaxeRuntime')
        return; //already there
    }

    modules.push({ Name:'HaxeRuntime', Type:'Runtime', LoadingPhase:'Default' });
    File.saveContent(projFile, haxe.Json.stringify(props));
  }
}
