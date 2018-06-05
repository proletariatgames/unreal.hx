package uhx.build;
import sys.FileSystem;
import haxe.DynamicAccess;

using StringTools;
using Lambda;

class GenerateProjectFiles extends UhxBaseBuild {
  var projectDir:String;

  public function new(data:UhxBuildData) {
    super(data);
    this.projectDir = haxe.io.Path.normalize(data.projectDir);
  }

  override public function run() {
    var vscodeDir = projectDir + '/.vscode';
    if (!FileSystem.exists(vscodeDir)) {
      FileSystem.createDirectory(vscodeDir);
    }

    this.changeSettings(vscodeDir + '/settings.json');
    if (this.config.debugger) {
      this.changeLaunch(vscodeDir + '/launch.json');
    }
  }

  function changeLaunch(file:String) {
    var existing:{ version:String, configurations: Array<{ name:String, type:String }> } = readJson(file);
    if (existing == null) {
      existing = { version: '0.2.0', configurations:[] };
    }

    inline function addOrReplace<T : { name:String }>(data:T) {
      var oldIdx = -1,
          cur = -1;
      for (conf in existing.configurations) {
        ++cur;
        if (conf.name == data.name) {
          oldIdx = cur;
          break;
        }
      }

      if (oldIdx >= 0) {
        var old = existing.configurations[oldIdx];
        for (field in Reflect.fields(old)) {
          if (Reflect.hasField(data, field)) {
            Reflect.setField(data, field, Reflect.field(old, field))
          }
        }
      }

      if (oldIdx >= 0) {
        existing.configurations[oldIdx] = cast data;
      } else {
        existing.configurations.unshift(data);
      }
    }

    addOrReplace({
      name: '(Unreal.hx) Attach to process',
      compileDir:
    });

  }

  function changeSettings(file:String) {
    var existing:DynamicAccess<Dynamic> = readJson(file);
    if (existing == null) {
      existing = {};
    }
    var exclude:DynamicAccess<Bool> = existing["files.exclude"];
    if (exclude == null) {
      exclude = {};
      exclude[projectDir + '/Intermediate'] = true;
      exclude[projectDir + '/Saved'] = true;
      exclude[projectDir + '/Content'] = true;
      exclude[projectDir + '/.git'] = true;
      exclude[projectDir + '/.vscode'] = true;
    } else {
      for (key in exclude.keys()) {
        if (key.endsWith('Haxe')) {
          exclude.remove(key);
        }
      }
    }

    var externsPath = haxe.io.Path.normalize(this.data.pluginData + '/Haxe/Externs');
    for (key in exclude.keys()) {
      if (key.startsWith(externsPath)) {
        exclude.remove(key);
      }
    }

    var version = this.getEngineVersion(this.config);

    var ueExternDir = 'UE${this.version.MajorVersion}.${this.version.MinorVersion}.${this.version.PatchVersion}';
    if (!FileSystem.exists('$externsPath/$ueExternDir')) {
      ueExternDir = 'UE${this.version.MajorVersion}.${this.version.MinorVersion}';
      if (!FileSystem.exists('$externsPath/$ueExternDir')) {
        throw new BuildError('Cannot find an externs directory for the unreal version ${this.version.MajorVersion}.${this.version.MinorVersion}');
      }
    }

    for (dir in FileSystem.readDirectory(externsPath)) {
      if (dir.startsWith('UE') && dir != ueExternsDir) {
        exclude[externsPath + '/' + dir] = true;
      }
    }

    var displayConfigs:Array<Array<String>> = existing["haxe.displayConfigurations"];
    if (
      displayConfigs == null ||
      displayConfigs.exists(function(args) return args[args.length-1] == "gen-compl-script.hxml")
    ) {
      if (displayConfigs == null) {
        existing["haxe.displayConfigurations"] = displayConfigs = [];
      }
      displayConfigs.unshift(['--cwd', '$projectDir/Haxe', 'gen-compl-script.hxml']);
    }

    if (this.config.haxeInstallPath != null || this.config.haxelibPath != null) {
      var data:{ path:String, ?env:Dynamic<String> } = { path:'haxe' };
      if (this.config.haxeInstallPath != null) {
        data.path = this.config.haxeInstallPath;
      }
      if (this.config.haxelibPath != null) {
        data.env = { HAXELIB_PATH: this.config.haxelibPath };
      }
      existing["haxe.executable"] = data;
    }

    saveJson(file, existing);
  }


  private static function readJson(file:String):Dynamic {
    var ret:Dynamic = null;
    if (FileSystem.exists(file)) {
      try {
        ret = haxe.Json.parse(sys.io.File.getContent(file));
      }
      catch(e:Dynamic) {
        throw new BuildError('Error while reading the json file $file: $e');
      }
    }
    return ret;
  }

  private static function saveJson(file:String, data:Dynamic) {
    try {
      sys.io.File.saveContent(file, haxe.Json.stringify(data, null, '\t'));
    }
    catch(e:Dynamic) {
      throw new BuildError('Error while saving the json file $file: $e');
    }
  }

}