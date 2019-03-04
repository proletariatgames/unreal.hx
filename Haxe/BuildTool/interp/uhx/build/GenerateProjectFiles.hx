package uhx.build;
import uhx.build.Log.*;
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
    if (this.config.skipVscodeGeneration)
    {
      log('Skipping vscode project generation');
      return;
    }
    var vscodeDir = data.rootDir + '/.vscode';
    if (!FileSystem.exists(vscodeDir)) {
      FileSystem.createDirectory(vscodeDir);
    }

    this.changeSettings(vscodeDir + '/settings.json');
    this.changeLaunch(vscodeDir + '/launch.json');
    this.changeTasks(vscodeDir + '/tasks.json');
  }

  function changeLaunch(file:String) {
    var existing:{ version:String, configurations: Array<{ name:String, type:String }> } = readJson(file);
    if (existing == null) {
      existing = { version: '0.2.0', configurations:[] };
    }

    function addOrReplace(data:Dynamic) {
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
            Reflect.setField(data, field, Reflect.field(old, field));
          }
        }
      }

      if (oldIdx >= 0) {
        existing.configurations[oldIdx] = cast data;
      } else {
        existing.configurations.unshift(data);
      }
    }

    var editorCall = null,
        editorCallDebug = null;
    switch(Sys.systemName())
    {
      case 'Linux':
        editorCall = 'Binaries/Linux/UE4Editor';
      case 'Mac':
        // TODO verify
        editorCall = 'Binaries/Mac/UE4Editor.app/Contents/MacOS/UE4Editor';
      case _: // default to Windows
        editorCall = 'Binaries/Win64/UE4Editor.exe';
        editorCallDebug = 'Binaries/Win64/UE4Editor-Win64-DebugGame.exe';
    }
    if (editorCallDebug == null)
    {
      editorCallDebug = editorCall + '-${Sys.systemName()}-DebugGame';
    }
    editorCall = this.data.engineDir + '/' + editorCall;
    editorCallDebug = this.data.engineDir + '/' + editorCallDebug;

    if (this.config.debugger)
    {
      addOrReplace({
        name: '(uhx) Attach to process',
        compileDir: this.data.projectDir + '/Haxe',
        type: "hxcpp",
        request: "attach"
      });
      addOrReplace({
        name: '(uhx) Run Editor - Development',
        compileDir: this.data.projectDir + '/Haxe',
        type: "hxcpp",
        request: "launch",
        run: {
          args: [
            editorCall,
            this.data.projectFile,
            '-stdout',
            '-AllowStdOutLogVerbosity'
          ],
          cwd: "${workspaceRoot}"
        },
        port: -1
      });
      addOrReplace({
        name: '(uhx) Run Editor - DebugGame',
        compileDir: this.data.projectDir + '/Haxe',
        type: "hxcpp",
        request: "launch",
        run: {
          args: [
            editorCallDebug,
            this.data.projectFile,
            '-stdout',
            '-AllowStdOutLogVerbosity',
            'RunConfig=Debug'
          ],
          cwd: "${workspaceRoot}"
        },
        port: -1
      });
      addOrReplace({
        name: '(uhx) Run Client - Development',
        compileDir: this.data.projectDir + '/Haxe',
        type: "hxcpp",
        request: "launch",
        run: {
          args: [
            editorCall,
            this.data.projectFile,
            '-game',
            '-stdout',
            '-AllowStdOutLogVerbosity'
          ],
          cwd: "${workspaceRoot}"
        },
        port: -1
      });
      addOrReplace({
        name: '(uhx) Run Client - DebugGame',
        compileDir: this.data.projectDir + '/Haxe',
        type: "hxcpp",
        request: "launch",
        run: {
          args: [
            editorCallDebug,
            this.data.projectFile,
            '-game',
            '-stdout',
            '-AllowStdOutLogVerbosity',
            'RunConfig=Debug'
          ],
          cwd: "${workspaceRoot}"
        },
        port: -1
      });
      if (this.config.serverDefaultMap != null)
      {
        addOrReplace({
          name: '(uhx) Run Server - Development',
          compileDir: this.data.projectDir + '/Haxe',
          type: "hxcpp",
          request: "launch",
          run: {
            args: [
              editorCall,
              this.data.projectFile,
              '-server',
              this.config.serverDefaultMap + '?listen',
              '-stdout',
              '-AllowStdOutLogVerbosity'
            ],
            cwd: "${workspaceRoot}"
          },
          port: -1
        });
        addOrReplace({
          name: '(uhx) Run Server - DebugGame',
          compileDir: this.data.projectDir + '/Haxe',
          type: "hxcpp",
          request: "launch",
          run: {
            args: [
              editorCallDebug,
              this.data.projectFile,
              '-server',
              this.config.serverDefaultMap + '?listen',
              '-stdout',
              '-AllowStdOutLogVerbosity',
              'RunConfig=Debug'
            ],
            cwd: "${workspaceRoot}"
          },
          port: -1
        });
      } else {
        addOrReplace({
          name: '(uhx) Run Server - Development',
          compileDir: this.data.projectDir + '/Haxe',
          type: "hxcpp",
          request: "launch",
          run: {
            args: [
              editorCall,
              this.data.projectFile,
              '-server',
              '-stdout',
              '-AllowStdOutLogVerbosity'
            ],
            cwd: "${workspaceRoot}"
          },
          port: -1
        });
        addOrReplace({
          name: '(uhx) Run Server - DebugGame',
          compileDir: this.data.projectDir + '/Haxe',
          type: "hxcpp",
          request: "launch",
          run: {
            args: [
              editorCallDebug,
              this.data.projectFile,
              '-server',
              '-stdout',
              '-AllowStdOutLogVerbosity',
              'RunConfig=Debug'
            ],
            cwd: "${workspaceRoot}"
          },
          port: -1
        });
      }
    }

    if (this.config.extraLaunchConfigurations != null)
    {
      for (config in this.config.extraLaunchConfigurations)
      {
        var newConfig = this.expandData(config);
        if (newConfig.name == null)
        {
          warn('The launch configuration added by the configuration "$newConfig" does not have a name');
          continue;
        } else {
          addOrReplace(newConfig);
        }
      }
    }

    saveJson(file, existing);
  }

  function changeTasks(file:String) {
    var existing:{ version:String, tasks: Array<{ label:String, type:String }>, options:{ env:DynamicAccess<String> } } = readJson(file);
    if (existing == null) {
      existing = { version: '0.2.0', tasks:[], options: { env:new DynamicAccess() } };
    }
    if (existing.options == null)
    {
      existing.options = { env: new DynamicAccess() };
    }
    if (existing.options.env == null)
    {
      existing.options.env = new DynamicAccess();
    }
    var env = existing.options.env;

    var path = env['PATH'];
    var separator = Sys.systemName() == 'Windows' ? ';' : ':';
    if (path == null)
    {
      path = '';
    }

    if (this.config.haxeInstallPath != null)
    {
      path = this.config.haxeInstallPath + separator + path;
      env['HAXEPATH'] = makeAbsolutePath(this.config.haxeInstallPath);
    }
    if (this.config.nekoInstallPath != null)
    {
      path = makeAbsolutePath(this.config.nekoInstallPath) + separator + path;
      env['NEKO_INSTPATH'] = makeAbsolutePath(this.config.haxeInstallPath);
    }
    if (this.config.haxelibPath != null)
    {
      env['HAXELIB_PATH'] = makeAbsolutePath(this.config.haxelibPath);
    }
    if (path != '')
    {
      env['PATH'] = path + separator + Sys.getEnv('PATH');
    }

    function addOrReplace(data:Dynamic) {
      var oldIdx = -1,
          cur = -1;
      for (conf in existing.tasks) {
        ++cur;
        if (conf.label == data.label) {
          oldIdx = cur;
          break;
        }
      }

      if (oldIdx >= 0) {
        existing.tasks[oldIdx] = cast data;
      } else {
        existing.tasks.unshift(data);
      }
    }

    var haxeProblemMatcher = {
      "owner": "haxe",
      "fileLocation" :"absolute",
      "pattern": {
          "regexp": "^(.+):(\\d+): (?:lines \\d+-(\\d+)|character(?:s (\\d+)-| )(\\d+)) : (?:(Warning) : )?(.*)$",
          "file": 1,
          "line": 2,
          "endLine": 3,
          "column": 4,
          "endColumn": 5,
          "severity": 6,
          "message": 7
      }
    };

    if (!this.config.disableCppia)
    {
      addOrReplace({
        label:'(uhx) Build Haxe/Scripts (cppia)',
        type: 'shell',
        command: 'haxe',
        args: ['--cwd','"$projectDir/Haxe"', 'gen-build-script.hxml'],
        group: 'build',
        presentation: { reveal:'always'},
        problemMatcher: haxeProblemMatcher
      });
    }

    if (this.config.extraVscodeTasks != null)
    {
      for (config in this.config.extraVscodeTasks)
      {
        var newConfig = this.expandData(config);
        if (newConfig.label == null)
        {
          warn('The vscode task added by the configuration "$newConfig" does not have a label');
          continue;
        } else {
          addOrReplace(newConfig);
        }
      }
    }
    saveJson(file, existing);
  }

  function expandData(dyn:Dynamic):Dynamic
  {
    if (Std.is(dyn, Array))
    {
      var arr:Array<Dynamic> = dyn;
      var ret = [];
      for (data in arr)
      {
        ret.push(expandData(data));
      }
      return ret;
    } else if (Std.is(dyn, String)) {
      var buf = new StringBuf();
      var cur:String = dyn;
      while (true)
      {
        var idx = cur.indexOf("${");
        if (idx < 0)
        {
          break;
        }
        buf.add(cur.substring(0, idx));
        var nameIdx = cur.indexOf("}", idx);
        if (nameIdx < 0)
        {
          cur = cur.substring(idx + 1);
          break;
        }
        var name = cur.substring(idx + 2, nameIdx);
        var data = Reflect.field(this.data, name);
        if (data != null && Std.is(data, String))
        {
          buf.add(data);
        } else {
          buf.add("${");
          buf.add(name);
          buf.add("}");
        }
        cur = cur.substring(nameIdx + 1);
      }
      buf.add(cur);
      return buf.toString();
    } else if (Reflect.isObject(dyn)) {
      var ret = {};
      for (field in Reflect.fields(dyn))
      {
        Reflect.setField(ret, field, expandData(Reflect.field(dyn, field)));
      }
      return ret;
    } else {
      return dyn;
    }
  }

  function makeAbsolutePath(path:String)
  {
    if (haxe.io.Path.isAbsolute(path))
    {
      return path;
    } else {
      return haxe.io.Path.normalize(this.data.projectDir + '/' + path);
    }
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
      if (this.config.extraExcludes != null)
      {
        for (exc in this.config.extraExcludes)
        {
          exclude[expandData(exc)] = true;
        }
      }
    } else {
      for (key in exclude.keys()) {
        if (key.endsWith('Haxe')) {
          exclude.remove(key);
        }
      }
      if (this.config.extraExcludes != null)
      {
        for (exc in this.config.extraExcludes)
        {
          exclude[haxe.io.Path.normalize(expandData(exc))] = true;
        }
      }
      if (this.config.extraEndsWithIncludes != null)
      {
        for (inc in this.config.extraEndsWithIncludes)
        {
          for (key in exclude.keys())
          {
            if (haxe.io.Path.normalize(key).endsWith(inc))
            {
              exclude.remove(key);
            }
          }
        }
      }
    }

    var externsPath = haxe.io.Path.normalize(this.data.pluginDir + '/Haxe/Externs');
    for (key in exclude.keys()) {
      if (key.startsWith(externsPath)) {
        exclude.remove(key);
      }
    }

    var version = this.getEngineVersion(this.config);

    var ueExternDir = 'UE${version.MajorVersion}.${version.MinorVersion}.${version.PatchVersion}';
    if (!FileSystem.exists('$externsPath/$ueExternDir')) {
      ueExternDir = 'UE${version.MajorVersion}.${version.MinorVersion}';
      if (!FileSystem.exists('$externsPath/$ueExternDir')) {
        throw new BuildError('Cannot find an externs directory for the unreal version ${version.MajorVersion}.${version.MinorVersion}');
      }
    }

    for (dir in FileSystem.readDirectory(externsPath)) {
      if (dir.startsWith('UE') && dir != ueExternDir) {
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
        data.path = makeAbsolutePath(this.config.haxeInstallPath) + '/haxe' + (Sys.systemName() == 'Windows' ? '.exe' : '');
      }
      if (this.config.haxelibPath != null) {
        data.env = { HAXELIB_PATH: makeAbsolutePath(this.config.haxelibPath) };
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