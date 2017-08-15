package uhx.build;
import haxe.io.Path;
import uhx.build.Log.*;
import sys.FileSystem;
import sys.io.File;

using Lambda;
using StringTools;

class UhxBuild {
  private static var VERSION_LEVEL = 5;

  public var data(default, null):UhxBuildData;
  var config:HaxeModuleConfig;
  var haxeDir:String;
  var targetModule:String;
  var definitions = [];
  var version:{ MajorVersion:Int, MinorVersion:Int, PatchVersion:Null<Int> };
  var srcDir:String;

  var scriptPaths:Array<String>;
  var modulePaths:Array<String>;
  var defineVer:String;
  var definePatch:String;
  var outputStatic:String;
  var outputDir:String;
  var buildName:String;
  var shortBuildName:String;
  var debugSymbols:Bool;
  var compserver:String;
  var externsFolder:String;
  var cppiaEnabled:Bool;

  public function new(data) {
    for (field in Reflect.fields(data)) {
      if (Reflect.field(data, field) == null) {
        var f = field.substr(0,1).toUpperCase() + field.substr(1);
        throw ('Cannot find property $f');
      }
    }

    this.data = data;
    this.haxeDir = data.projectDir + '/Haxe';
    this.config = getConfig();
    this.targetModule = this.data.targetName;
    if (this.targetModule.endsWith("Editor")) {
      this.targetModule = this.targetModule.substr(0,this.targetModule.length - "Editor".length);
    }
    this.version = getEngineVersion(this.config);
    this.srcDir = this.getSourceDir();
  }

  private function getConfig():HaxeModuleConfig {
    var base:HaxeModuleConfig = {};
    for (file in ['uhxconfig.json','uhxconfig-local.json','uhxconfig.local']) {
      if (FileSystem.exists('${data.projectDir}/$file')) {
        trace('Loading config from ${data.projectDir}/$file');
        var cur = haxe.Json.parse(File.getContent('${data.projectDir}/$file'));
        for (field in Reflect.fields(cur)) {
          var data:Dynamic = Reflect.field(cur, field);
          if (Std.is(data, Array)) {
            var old:Array<Dynamic> = Reflect.field(base, field);
            if (old != null && Std.is(old, Array)) {
              data = old.concat(data);
            }
          }
          Reflect.setField(base, field, data);
        }
      }
    }

    if (Sys.getEnv('BAKE_EXTERNS') != null) {
      base.forceBakeExterns = true;
    }
    if (Sys.getEnv('DCE_FULL') != null) {
      base.dce = DceFull;
    } else if (Sys.getEnv('NO_DCE') != null) {
      base.dce = DceNo;
    } else if (data.targetConfiguration == Shipping) {
      base.dce = DceFull;
    }

    return base;
  }

  inline private function shouldBuildEditor() {
    return data.targetType == Editor;
  }

  private function shouldCompileCppia() {
    if (this.data.targetType == Program) {
      return false;
    }

    if (this.config.disableCppia) {
      return false;
    }

    var buildEditor = shouldBuildEditor();

    if (!buildEditor) {
      // only editor builds will use cppia
      return false;
    }

    if (this.config.dce != null && this.config.dce != DceNo) {
      trace('DCE enabled: cppia will be disabled');
      return false;
    }
    return true;
  }

  private function getLibLocation() {
    var libName = switch(data.targetPlatform) {
      case Win64 | Win32 | XboxOne: // TODO: see if XboxOne follows windows' path names
        'haxeruntime.lib';
      case _:
        'libhaxeruntime.a';
    };
    var config = data.targetConfiguration;
    if (config == DebugGame) {
      config = Development;
    }
    var platform = data.targetPlatform;
    switch(platform) {
    case Win32 | Win64 | WinRT | WinRT_ARM:
      platform = "Win";
    case _:
    }
    this.buildName = '${targetModule}-${platform}-${config}-${data.targetType}';
    var bn = this.buildName.split('-');
    bn.shift();
    switch(bn[1]) {
    case 'Development':
      bn[1] = 'Dev';
    case 'Shipping':
      bn[1] = 'Ship';
    case 'Debug':
      bn[1] = 'Dbg';
    }
    this.shortBuildName = bn.join('-');
    this.outputDir = this.data.projectDir + '/Intermediate/Haxe/$buildName';
    if (!FileSystem.exists(this.outputDir + '/Data')) {
      FileSystem.createDirectory(this.outputDir + '/Data');
    }

    return '$outputDir/$libName';
  }

  private function checkRecursive(stampPath:String, paths:Array<String>, traceFiles:Bool) {
    if (!FileSystem.exists(stampPath)) {
      if (traceFiles) {
        log('File $stampPath does not exist');
      }
      return true; // the file needs to be rebuilt
    }

    var stamp = FileSystem.stat(stampPath).mtime.getTime();
    if (FileSystem.exists('${haxeDir}/arguments.hxml')) {
      if (FileSystem.stat('$haxeDir/arguments.hxml').mtime.getTime() >= stamp) {
        return true;
      }
    }
    paths.push('${data.pluginDir}/Haxe/Static/uhx/compiletime');

    function recurse(path) {
      for (file in FileSystem.readDirectory(path)) {
        if (file.endsWith('.hx')) {
          if (FileSystem.stat('$path/$file').mtime.getTime() >= stamp) {
            if (traceFiles) {
              log('File $path/$file has changed');
            }
            return true;
          }
        } else if (FileSystem.isDirectory('$path/$file')) {
          var ret = recurse('$path/$file');
          if (ret) {
            return true;
          }
        }
      }
      return false;
    }
    for (path in paths) {
      if (FileSystem.exists(path)) {
        if (recurse(path)) {
          return true;
        }
      }
    }
    return false;
  }

  public function getSourceDir() {
    var srcDir = '${this.data.projectDir}/Source';
    if (!FileSystem.exists(srcDir)) {
      err('getSourceDir(): The directory ${this.data.projectDir}/Source does not exist');
      return null;
    }
    if (FileSystem.exists('$srcDir/$targetModule')) {
      return '$srcDir/$targetModule';
    }
    var dirs = [];
    for (file in FileSystem.readDirectory(srcDir)) {
      var path = '$srcDir/$file';
      if (FileSystem.isDirectory(path)) {
        dirs.push(file);
      }
    }

    if (dirs.length == 0) {
      err('No source dir was found at ${this.data.projectDir}/Source');
      return null;
    } else if (dirs.length == 1) {
      return '$srcDir/${dirs[0]}';
    } else {
      err('Found more than one potential target source directory (${dirs.join(", ")})');
      return null;
    }
  }

  private function findUhtManifest(target:String) {
    var base = this.data.projectDir + '/Intermediate/Build/$target';
    if (!FileSystem.exists(base)) {
      err('Giving up on finding a previous UHT manifest because $base could not be found: perhaps this is the first build?');
      return null;
    }

    function testPath(path:String) {
      if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
        for (file in FileSystem.readDirectory(path)) {
          if (file.toLowerCase().endsWith('.uhtmanifest')) {
            return '$path/$file';
          }
        }
      }
      return null;
    }
    function testTarget(targetName:String) {
      if (FileSystem.exists('$base/${targetName}')) {
        var ret = testPath('$base/${targetName}/${this.data.targetConfiguration}');
        if (ret != null) {
          return ret;
        }
        var path = '$base/${targetName}';
        for (file in FileSystem.readDirectory(path)) {
          var ret = testPath('$path/$file');
          if (ret != null) {
            return ret;
          }
        }
      }
      return null;
    }
    var ret = testTarget(this.data.targetName + 'Editor');
    if (ret != null) {
      return ret;
    }
    ret = testTarget(this.data.targetName);
    if (ret != null) {
      return ret;
    }

    for (dir in FileSystem.readDirectory(base)) {
      if (FileSystem.isDirectory('$base/$dir')) {
        for (file in FileSystem.readDirectory('$base/$dir')) {
          if (FileSystem.isDirectory('$base/$dir/$file')) {
            var ret = testPath('$base/$dir/$file');
            if (ret != null) {
              return ret;
            }
          }
        }
      }
    }
    return null;
  }

  private function generateExterns() {
    var target = switch(Sys.systemName()) {
      case 'Windows':
        'Win64';
      case 'Mac':
        'Mac';
      case 'Linux':
        'Linux';
      case _:
        throw 'assert';
    };
    var baseManifest = findUhtManifest(target);
    if (baseManifest == null) {
      err('No prebuilt manifest found for version ${version.MajorVersion}.${version.MinorVersion}. Cannot generate externs');
      return;
    }
    log('Found base UHT manifest: $baseManifest');

    var proj:{ Modules:Array<{Name:String}>, Plugins:Array<{Name:String, Enabled:Bool}> } = haxe.Json.parse(sys.io.File.getContent(this.data.projectFile));
    var targets = [{ name:this.targetModule, path:this.srcDir, headers:[] }],
        uhtDir = this.outputDir + '/UHT';

    if (proj.Modules != null) {
      for (module in proj.Modules) {
        if (module.Name != this.targetModule) {
          var targetPath = this.srcDir + '/../' + module.Name;
          if (FileSystem.exists(targetPath)) {
            targets.push({ name:module.Name, path:targetPath, headers:[] });
          } else {
            warn('The target ${module.Name}\'s path was not found (assumed $targetPath). Ignoring');
          }
        }
      }
    }
    if (proj.Plugins != null) {
      var plugins = new Map();
      for (plugin in proj.Plugins) {
        plugins[plugin.Name.toLowerCase()] = true;
      }
      for (plugin in FileSystem.readDirectory(this.data.projectDir + '/Plugins')) {
        var path = this.data.projectDir + '/Plugins/' + plugin;
        if (FileSystem.isDirectory(path)) {
          for (file in FileSystem.readDirectory(path)) {
            if (file.toLowerCase().endsWith('.uplugin')) {
              var name = file.substr(0,file.length - '.uplugin'.length).toLowerCase();
              if (plugins.exists(name)) {
                var proj:{ Modules:Array<{Name:String}> } = haxe.Json.parse(sys.io.File.getContent('$path/$file'));
                if (proj.Modules != null) {
                  for (mod in proj.Modules) {
                    if (FileSystem.exists('$path/Source/${mod.Name}')) {
                      targets.push({ name:mod.Name, path:'$path/Source/${mod.Name}', headers:[] });
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    var lastRun = FileSystem.exists('$uhtDir/generated.stamp') ? FileSystem.stat('$uhtDir/generated.stamp').mtime.getTime() : 0.0;
    var shouldRun = lastRun == 0;

    if (!shouldRun) {
      log('Skipping extern generation because no new header was found on the project');
      return;
    }
    var manifest:UhtManifest = haxe.Json.parse(sys.io.File.getContent(baseManifest));
    if (!FileSystem.exists(uhtDir)) {
      FileSystem.createDirectory(uhtDir);
    }
    if (!FileSystem.exists('$uhtDir/deps.deps')) {
      sys.io.File.saveContent('$uhtDir/deps.deps', '');
    }
    manifest.RootLocalPath = this.data.engineDir + '/..';
    manifest.RootBuildPath = this.data.engineDir + '/../';
    manifest.ExternalDependenciesFile = '$uhtDir/deps.deps';
    manifest.TargetName = this.targetModule;
    // manifest.Modules = manifest.Modules.filter(function(v) return !targets.exists(function (target) return target.name == v.Name));

    for (target in targets) {
      var old = manifest.Modules.find(function(v) return v.Name == target.name);
      if (old == null) {
        old = {
          Name: target.name,
          ModuleType: 'GameRuntime',
          BaseDirectory: target.path,
          IncludeBase: target.path,
          OutputDirectory: uhtDir,
          ClassesHeaders: [],
          PublicHeaders: [],
          PrivateHeaders: [],
          PCH: "",
          GeneratedCPPFilenameBase: uhtDir + '/' + target.name + '.generated',
          SaveExportedHeaders: false,
          UHTGeneratedCodeVersion: 'None'
        }
        manifest.Modules.push(old);
      }
      old.SaveExportedHeaders = false;
      var concat = old.PublicHeaders.concat(old.PrivateHeaders).concat(old.ClassesHeaders);
      old.ClassesHeaders = [];
      old.PrivateHeaders = [];
      old.PublicHeaders = concat;
      shouldRun = collectUhtHeaders(target.path, concat, lastRun) || shouldRun;
    }

    sys.io.File.saveContent(uhtDir + '/externs.uhtmanifest', haxe.Json.stringify(manifest));
    proj.Plugins = [{ Name:'UnrealHxGenerator', Enabled:true }];
    sys.io.File.saveContent(uhtDir + '/proj.uproject', haxe.Json.stringify(proj));
    // Call UHT
    var oldEnvs = setEnvs([
      'GENERATE_EXTERNS' => '1',
      'EXTERN_MODULES' => [ for (target in targets) target.name ].join(','),
      'EXTERN_OUTPUT_DIR' => this.data.projectDir
    ]);
    var args = [uhtDir + '/proj.uproject','$uhtDir/externs.uhtmanifest', '-PLUGIN=UnrealHxGenerator', '-Unattended', '-stdout'];
    if (config.verbose) {
      args.push('-AllowStdOutLogVerbosity');
    }

    if (this.callUHT(args) != 0) {
      warn('==========================================================');
      warn('UHT: Unable to generate the externs. Build will continue');
      warn('==========================================================');
    } else {
      sys.io.File.saveContent('$uhtDir/generated.stamp', '');
    }
    if (oldEnvs != null) {
      setEnvs(oldEnvs);
    }
  }

  private static function collectUhtHeaders(dir:String, arr:Array<String>, lastRun:Float):Bool {
    var processed = new Map();
    for (a in arr) {
      processed[haxe.io.Path.withoutDirectory(a).toLowerCase()] = true;
    }

    function recurse(path:String, recursive:Bool) {
      var shouldRun = false;
      for (file in FileSystem.readDirectory(path)) {
        var path = '$path/$file';
        var f = file.toLowerCase();
        if (f.endsWith('.h')) {
          if (lastRun != 0 && !shouldRun && recursive) {
            shouldRun = FileSystem.stat(path).mtime.getTime() >= lastRun;
          }

          if (!processed.exists(f)) {
            arr.push(path);
          }
        } else if (recursive && FileSystem.isDirectory(path)) {
          var ret = recurse(path, f != 'generated');
          if (ret) {
            shouldRun = true;
          }
        }
      }
      return shouldRun;
    }
    return recurse(dir, true);
  }

  private function expandVariables(str:String, target:String) {
    var idx = str.indexOf('$');
    if (idx < 0) {
      return str;
    }

    var buf = new StringBuf(),
        lastIdx = -1;
    buf.add(str.substring(0, idx));
    do {
      var next = str.indexOf('/',idx);
      if (next < 0) {
        next = str.length;
      }
      switch(str.substring(idx, next)) {
      case "$EngineDir":
        buf.add(this.data.engineDir);
      case "$TargetPlatform":
        buf.add(target);
      case i:
        warn('Unknown identifier $i at "$str"');
        buf.add(i);
      }
      lastIdx = next;
      idx = str.indexOf('$', next);
    } while (idx >= 0);

    if (lastIdx >= 0) {
      buf.add(str.substr(lastIdx));
    }
    return buf.toString();
  }

  private function getStaticCps() {
    var cps = [
      'arguments.hxml',
      '-cp $haxeDir/Generated/$externsFolder',
      '-cp ${data.pluginDir}/Haxe/Static',
    ];

    for (path in this.modulePaths) {
      cps.push('-cp $path');
    }
    return cps;
  }

  private function bakeExterns() {
    // Windows paths have '\' which needs to be escaped for macro arguments
    var escapedHaxeDir = haxeDir.replace('\\','\\\\');
    var escapedPluginPath = data.pluginDir.replace('\\','\\\\');
    var forceCreateExterns = this.config.forceBakeExterns == null ? Sys.getEnv('BAKE_EXTERNS') != null : this.config.forceBakeExterns;

    var ueExternDir = 'UE${this.version.MajorVersion}.${this.version.MinorVersion}.${this.version.PatchVersion}';
    if (!FileSystem.exists('${data.pluginDir}/Haxe/Externs/$ueExternDir')) {
      ueExternDir = 'UE${this.version.MajorVersion}.${this.version.MinorVersion}';
      if (!FileSystem.exists('${data.pluginDir}/Haxe/Externs/$ueExternDir')) {
        throw ('Cannot find an externs directory for the unreal version ${this.version.MajorVersion}.${this.version.MinorVersion}');
      }
    }

    var targetStamp = '$haxeDir/Generated/$externsFolder/externs.stamp';
#if UE_EDITOR_RECOMPILE
    var shouldRun = !this.cppiaEnabled ||
      checkRecursive(targetStamp, [
        '${data.pluginDir}/Haxe/Static/uhx/compiletime'
      ], false) ||
      checkRecursive(targetStamp, [
        '${haxeDir}/Externs',
        '${data.pluginDir}/Haxe/Externs/$ueExternDir',
        '${data.pluginDir}/Haxe/Externs/Common',
      ], false);
    if (!shouldRun) {
      log('Skipping extern baker, as no file has changed. Delete $haxeDir/Generated/$externsFolder to force');
      return 0;
    }
#end

    var bakeArgs = [
      '# this pass will bake the extern type definitions into glue code',
      FileSystem.exists('$haxeDir/baker-arguments.hxml') ? 'baker-arguments.hxml' : '',
      '-cp ${data.pluginDir}/Haxe/Static',
      '-D use-rtti-doc', // we want the documentation to be persisted
      '-D bake-externs',
      '-D ${this.defineVer}',
      '-D ${this.definePatch}',
      '',
      '-cpp $haxeDir/Generated/$externsFolder',
      '--no-output', // don't generate cpp files; just execute our macro
      '--macro uhx.compiletime.main.ExternBaker.process(["$escapedPluginPath/Haxe/Externs/Common", "$escapedPluginPath/Haxe/Externs/$ueExternDir", "$escapedHaxeDir/Externs"], $forceCreateExterns)'
    ];
    if (shouldBuildEditor()) {
      bakeArgs.push('-D WITH_EDITOR');
      bakeArgs.push('-D WITH_EDITORONLY_DATA');
    }
    if (data.targetType == Program) {
      bakeArgs.push('-D IS_PROGRAM');
    }
    if (this.config.disableUObject) {
      bakeArgs.push('-D UHX_NO_UOBJECT');
    }

    trace('baking externs');
    var tbake = timer('bake externs');
    bakeArgs.push('-D BUILDTOOL_VERSION_LEVEL=$VERSION_LEVEL');
    var ret = compileSources(bakeArgs);
    tbake();
    this.createHxml('bake-externs', bakeArgs);
    if (ret == 0) {
      sys.io.File.saveContent(targetStamp, '');
    }
    return ret;
  }

  private static function addConfigurationDefines(defines:Array<String>, config:TargetConfiguration) {
    switch(config) {
      case Development | DebugGame:
        defines.push('-D UE_BUILD_DEVELOPMENT');
      case Shipping:
        defines.push('-D UE_BUILD_SHIPPING');
      case Debug:
        defines.push('-D UE_BUILD_DEBUG');
      case Test:
        defines.push('-D UE_BUILD_TEST');
    }
  }

  private static function addTargetDefines(defines:Array<String>, type:TargetType) {
    switch(type) {
      case Game:
        defines.push('-D UE_GAME');
        defines.push('-D WITH_SERVER_CODE');
      case Client:
        defines.push('-D UE_GAME');
      case Editor:
        defines.push('-D WITH_SERVER_CODE');
        defines.push('-D WITH_EDITOR');
        defines.push('-D WITH_EDITORONLY_DATA');
        defines.push('-D UE_EDITOR');
      case Server:
        defines.push('-D WITH_SERVER_CODE');
        defines.push('-D UE_SERVER');
      case Program:
        defines.push('-D IS_PROGRAM');
    }
  }

  private static function addPlatformDefines(defines:Array<String>, platform:TargetPlatform) {
    switch(platform) {
      case Win32 | Win64 | WinRT | WinRT_ARM:
        defines.push('-D PLATFORM_WINDOWS');
      case Mac:
        defines.push('-D PLATFORM_MAC');
      case XboxOne:
        defines.push('-D PLATFORM_XBOXONE');
      case PS4:
        defines.push('-D PLATFORM_PS4');
      case IOS:
        defines.push('-D PLATFORM_IOS');
      case Android:
        defines.push('-D PLATFORM_ANDROID');
      case HTML5:
        defines.push('-D PLATFORM_HTML5');
      case Linux:
        defines.push('-D PLATFORM_LINUX');
      case TVOS:
        defines.push('-D PLATFORM_TVOS');
      case _:
        throw 'Unknown platform $platform';
    }
  }

  private function compileCppia() {
    var cps = getStaticCps();
    for (module in scriptPaths) {
      cps.push('-cp $module');
    }

    var args = cps.concat([
        '',
        '-main UnrealCppia',
        '',
        '-D cppia',
        '-D ${this.defineVer}',
        '-D ${this.definePatch}',
        '-D UHX_STATIC_BASE_DIR=$outputDir',
        '-D UHX_PLUGIN_PATH=${data.pluginDir}',
        '-D UHX_UE_CONFIGURATION=${data.targetConfiguration}',
        '-D UHX_UE_TARGET_TYPE=${data.targetType}',
        '-D UHX_UE_TARGET_PLATFORM=${data.targetPlatform}',
        '-D UHX_BUILD_NAME=$buildName',
#if (!UE_EDITOR_RECOMPILE && !UE_EDITOR_COMPILE)
        '-cppia ${data.projectDir}/Binaries/Haxe/game.cppia',
#else
        '-cppia ${data.projectDir}/Binaries/Haxe/game-editor.cppia',
#end
        '--macro uhx.compiletime.main.CreateCppia.run(' +toMacroDef(this.modulePaths) +', ' + toMacroDef(scriptPaths) + ',' + (config.cppiaModuleExclude == null ? 'null' : toMacroDef(config.cppiaModuleExclude)) + ')',
    ]);
    if (debugSymbols) {
      args.push('-debug');
    }
    if (this.config.noGlueUnityBuild) {
      args.push('-D no_unity_build');
    }
    addTargetDefines(args, data.targetType);
    addConfigurationDefines(args, data.targetConfiguration);
    if (config.extraCppiaCompileArgs != null) {
      args = args.concat(config.extraCppiaCompileArgs);
    }

    if (!FileSystem.exists('${data.projectDir}/Binaries/Haxe')) {
      FileSystem.createDirectory('${data.projectDir}/Binaries/Haxe');
    }

    var extraArgs = ['-D use-rrti-doc'];
    if (this.compserver != null) {
      extraArgs.push('--connect ${this.compserver}');
    }
    var tcppia = timer('Cppia compilation');
    args.push('-D BUILDTOOL_VERSION_LEVEL=$VERSION_LEVEL');
    var cppiaRet = compileSources(extraArgs.concat(args));

    tcppia();
#if (!UE_EDITOR_RECOMPILE && !UE_EDITOR_COMPILE)
    this.createHxml('build-script', args.concat(['-D use-rrti-doc']));
    var complArgs = ['--cwd ${data.projectDir}/Haxe', '--no-output'].concat(args);
    this.createHxml('compl-script', complArgs.filter(function(v) return !v.startsWith('--macro')));
#end
    return cppiaRet;
  }

  private function compileStatic() {
    trace('compiling Haxe');
    if (!FileSystem.exists('$outputDir/Static')) FileSystem.createDirectory('$outputDir/Static');

#if (UE_EDITOR_RECOMPILE || UE_EDITOR_COMPILE)
    var curStamp:Null<Date> = null;
    if (FileSystem.exists(this.outputStatic)) {
      curStamp = FileSystem.stat(this.outputStatic).mtime;
    }
#end


    var curSourcePath = this.srcDir;
    var cps = getStaticCps();
    var args = cps.concat([
      '',
      '-main UnrealInit',
      '',
      '-D static_link',
      '-D destination=${this.outputStatic}',
      '-D UHX_UNREAL_SOURCE_DIR=$curSourcePath',
      '-D UHX_PLUGIN_PATH=${data.pluginDir}',
      '-D UHX_UE_CONFIGURATION=${data.targetConfiguration}',
      '-D UHX_UE_TARGET_TYPE=${data.targetType}',
      '-D UHX_UE_TARGET_PLATFORM=${data.targetPlatform}',
      '-D UHX_BAKE_DIR=$haxeDir/Generated/$externsFolder',
      '-D UHX_BUILD_NAME=$buildName',
      '-D HXCPP_DLL_EXPORT',
      '-D ${this.defineVer}',
      '-D ${this.definePatch}',

      '-cpp $outputDir/Static',
      '--macro uhx.compiletime.main.CreateGlue.run(' +toMacroDef(this.modulePaths) +', ' + toMacroDef(this.scriptPaths) + ')',
    ]);
    if (!FileSystem.exists('$outputDir/Data')) {
      FileSystem.createDirectory('$outputDir/Data');
    }
    if (!FileSystem.exists('$outputDir/Static/toolchain')) {
      FileSystem.createDirectory('$outputDir/Static/toolchain');
    }
    for (file in FileSystem.readDirectory('${data.pluginDir}/Haxe/BuildTool/toolchain')) {
      File.saveBytes('$outputDir/Static/toolchain/$file', File.getBytes('${data.pluginDir}/Haxe/BuildTool/toolchain/$file'));
    }

    addTargetDefines(args, data.targetType);
    addConfigurationDefines(args, data.targetConfiguration);
    addPlatformDefines(args, data.targetPlatform);
    if (this.config.disableUObject || data.targetType == Program) {
      args.push('-D UHX_NO_UOBJECT');
    }
    if (this.config.noGlueUnityBuild) {
      args.push('-D no_unity_build');
    }

    if (this.config.dce != null) {
      args.push('-dce ${this.config.dce}');
    }

    if (debugSymbols) {
      args.push('-debug');
      if (this.config.debugger) {
        args.push('-lib hxcpp-debugger');
        args.push('-D HXCPP_DEBUGGER');
      }
    }

    switch (data.targetPlatform) {
    case Win32:
      args.push('-D HXCPP_M32');
      if (debugSymbols)
        args.push('-D HXCPP_DEBUG_LINK');
    case Win64:
      args.push('-D HXCPP_M64');
    case _:
      args.push('-D HXCPP_M64');
    }

    // set correct ABI
    switch (data.targetPlatform) {
    case Win64 | Win32 | XboxOne: // TODO: see if XboxOne follows windows' path names
      args.push('-D ABI=-MD');
    case _:
    }

    var noDynamicUClass = config.noDynamicUClass;
    if (this.cppiaEnabled) {
      args = args.concat(['-D scriptable', '-D WITH_CPPIA']);
    } else {
      noDynamicUClass = true;
    }
    if (noDynamicUClass) {
      args = args.concat(['-D NO_DYNAMIC_UCLASS']);
      this.definitions.push("NO_DYNAMIC_UCLASS=1");
    }

    var isCrossCompiling = false;
    var extraArgs = null,
        oldEnvs = null;
    var thirdPartyDir = this.data.engineDir + '/Source/ThirdParty';
    Sys.putEnv('ThirdPartyDir', thirdPartyDir);
    switch(Std.string(data.targetPlatform)) {
    case "Linux" if (Sys.systemName() != "Linux"):
      // cross compiling
      isCrossCompiling = true;
      var crossPath = Sys.getEnv("LINUX_MULTIARCH_ROOT");
      if (crossPath != null) {
        crossPath = '$crossPath/x86_64-unknown-linux-gnu';
      } else {
        crossPath = Sys.getEnv("LINUX_ROOT");
      }

      if (crossPath != null) {
        trace('Cross compiling using $crossPath');
        extraArgs = [
          '-D toolchain=linux',
          '-D linux',
          '-D HXCPP_CLANG',
          '-D xlinux_compile',
          '-D magiclibs',
          '-D HXCPP_VERBOSE'
        ];
        oldEnvs = setEnvs([
          'PATH' => Sys.getEnv("PATH") + (Sys.systemName() == "Windows" ? ";" : ":") + crossPath + '/bin',
          'CXX' => (Sys.getEnv("CROSS_LINUX_SYMBOLS") == null ?
            'clang++ --sysroot "$crossPath" -target x86_64-unknown-linux-gnu -nostdinc++ \"-I$${ThirdPartyDir}/Linux/LibCxx/include\" \"-I$${ThirdPartyDir}/Linux/LibCxx/include/c++/v1\"' :
            'clang++ --sysroot "$crossPath" -target x86_64-unknown-linux-gnu -g -nostdinc++ \"-I$${ThirdPartyDir}/Linux/LibCxx/include\" \"-I$${ThirdPartyDir}/Linux/LibCxx/include/c++/v1\"'),
          'CC' => 'clang --sysroot "$crossPath" -target x86_64-unknown-linux-gnu',
          'HXCPP_AR' => 'x86_64-unknown-linux-gnu-ar',
          'HXCPP_AS' => 'x86_64-unknown-linux-gnu-as',
          'HXCPP_LD' => 'x86_64-unknown-linux-gnu-ld',
          'HXCPP_RANLIB' => 'x86_64-unknown-linux-gnu-ranlib',
          'HXCPP_STRIP' => 'x86_64-unknown-linux-gnu-strip'
        ]);
      } else {
        warn('Cross-compilation was detected but no LINUX_ROOT environment variable was set');
      }
    case "Linux" if(!shouldBuildEditor()):
      oldEnvs = setEnvs([
          'CXX' => "clang++ -nostdinc++ \"-I${ThirdPartyDir}/Linux/LibCxx/include\" \"-I${ThirdPartyDir}/Linux/LibCxx/include/c++/v1\"",
      ]);
    case "Mac":
      extraArgs = [
        '-D toolchain=mac-libc'
      ];
    }

    if (extraArgs != null) {
      args = args.concat(extraArgs);
    }
    if (this.config.extraCompileArgs != null) {
      args = args.concat(this.config.extraCompileArgs);
    }

    var compileOnlyArgs = ['-D use-rtti-doc'];
    if (this.compserver != null) {
      File.saveContent('$outputDir/Data/compserver.txt','1');
      // Sys.putEnv("HAXE_COMPILATION_SERVER", this.compserver);
      compileOnlyArgs.push('--connect ${this.compserver}');
    } else {
      File.saveContent('$outputDir/Data/compserver.txt','0');
    }

    var thaxe = timer('Haxe compilation');
    args.push('-D BUILDTOOL_VERSION_LEVEL=$VERSION_LEVEL');
    var ret = compileSources(args.concat(compileOnlyArgs));
    thaxe();
    if (!isCrossCompiling) {
      this.createHxml('build-static', args.concat(['-D use-rtti-doc']));
      var complArgs = ['--cwd $haxeDir', '--no-output'].concat(args);
      this.createHxml('compl-static', complArgs.filter(function(v) return !v.startsWith('--macro')));
    }

    if (oldEnvs != null) {
      setEnvs(oldEnvs);
    }

    if (ret == 0 && isCrossCompiling) {
      // somehow -D destination doesn't do anything when cross compiling
      var hxcppDestination = '$outputDir/Static/libUnrealInit';
      if (debugSymbols) {
        hxcppDestination += '-debug.a';
      } else {
        hxcppDestination += '.a';
      }

      var shouldCopy =
        !FileSystem.exists(this.outputStatic) ||
        (FileSystem.exists(hxcppDestination) &&
         FileSystem.stat(hxcppDestination).mtime.getTime() > FileSystem.stat(this.outputStatic).mtime.getTime());
      if (shouldCopy) {
        File.saveBytes(this.outputStatic, File.getBytes(hxcppDestination));
      }
    }

#if (UE_EDITOR_RECOMPILE || UE_EDITOR_COMPILE)
    if (ret == 0 && (curStamp == null || FileSystem.stat(outputStatic).mtime.getTime() > curStamp.getTime()))
    {
      // when compiling through the editor, -skiplink is set - so UBT won't even try to find the right
      // dependencies unless we give it a little nudge
      var dep = this.config.noGlueUnityBuild ?
        '${this.srcDir}/Generated/HaxeInit.cpp' :
        '${this.srcDir}/Generated/Unity/${shortBuildName}/HaxeRuntime.${shortBuildName}.uhxglue.cpp';
      trace('Touching $dep to trigger hot-reload');
      // touch the file
      File.saveContent(dep, File.getContent(dep));
    }
#end

    return ret;
  }

  private function callUnrealBuild(platform:Null<String>, project:String, config:String, ?extraArgs:Array<String>) {
    var args = [];
    var path = switch(Sys.systemName()) {
      case 'Windows':
        if (platform == null) {
          platform = 'Win64';
        }
        this.data.engineDir + '/Build/BatchFiles/Build.bat';
      case 'Mac':
        if (platform == null) {
          platform = 'Mac';
        }
        this.data.engineDir + '/Build/BatchFiles/Mac/Build.sh';
      case 'Linux':
        if (platform == null) {
          platform = 'Linux';
        }
        this.data.engineDir + '/Build/BatchFiles/Linux/Build.sh';
      case name:
        warn('Cannot call unreal build for platform $name');
        return 1;
    };

    return this.call(path, [platform,project,config].concat(extraArgs == null ? [] : extraArgs), true);
  }

  private function callUHT(args:Array<String>) {
    var path = switch(Sys.systemName()) {
      case 'Windows':
        this.data.engineDir + '/Binaries/Win64/UnrealHeaderTool.exe';
      case 'Mac':
        this.data.engineDir + '/Binaries/Mac/UnrealHeaderTool';
      case 'Linux':
        this.data.engineDir + '/Binaries/Linux/UnrealHeaderTool';
      case name:
        warn('Cannot call unreal header tool for platform $name');
        return 1;
    };

    log('Calling UHT ${args}');
    return this.call(path, args, true);
  }

  private function hasProjectEnabled(name:String) {
    var uproject:{ Plugins:Array<{ Name:String, Enabled:Bool }> } = haxe.Json.parse(sys.io.File.getContent( data.projectFile ));
    if (uproject.Plugins == null) {
      return false;
    }
    for (p in uproject.Plugins) {
      if (p.Name == name) {
        return p.Enabled;
      }
    }
    return false;
  }

  private function setupVars() {
    this.defineVer = 'UE_VER=${this.version.MajorVersion}.${this.version.MinorVersion}';
    this.definePatch = 'UE_PATCH=${this.version.PatchVersion == null ? 0 : this.version.PatchVersion}';
    this.outputStatic = getLibLocation();
    this.debugSymbols = data.targetConfiguration != Shipping && config.noDebug != true;
    if (config.noDebug == false) {
      this.debugSymbols = false;
    }
    if (config.compilationServer != null) {
      this.compserver = Std.string(config.compilationServer);
    }
    if (this.compserver == null) {
      this.compserver = Sys.getEnv("HAXE_COMPILATION_SERVER_DEFER");
    }
    if (this.compserver == null || this.compserver == '') {
      this.compserver = Sys.getEnv("HAXE_COMPILATION_SERVER");
    }
    if (this.compserver == '') {
      this.compserver = null;
    }

    this.externsFolder = shouldBuildEditor() ? 'Externs_Editor' : 'Externs';

    // get all modules that need to be compiled
    this.modulePaths = ['$haxeDir/Static'];
    this.scriptPaths = ['$haxeDir/Scripts'];
    if (this.config.extraStaticClasspaths != null) {
      this.modulePaths = this.modulePaths.concat(this.config.extraStaticClasspaths);
    }
    if (this.config.extraScriptClasspaths != null) {
      this.scriptPaths = this.scriptPaths.concat(this.config.extraScriptClasspaths);
    }
    if (this.config.noStatic) {
      this.scriptPaths = this.modulePaths.concat(this.scriptPaths);
      this.modulePaths = [];
    }
    this.cppiaEnabled = shouldCompileCppia();
    if (!this.cppiaEnabled) {
      this.modulePaths = this.modulePaths.concat(this.scriptPaths);
      this.scriptPaths = [];
    }
  }

  public function run()
  {
    if (srcDir == null) {
      throw 'Build failed';
    }
    this.setupVars();

    if (!FileSystem.exists(haxeDir)) {
      FileSystem.createDirectory(haxeDir);
    }
    if (!FileSystem.exists('$haxeDir/arguments.hxml')) {
      sys.io.File.saveContent('$haxeDir/arguments.hxml',
          '# put here your additional haxe arguments\n' +
          '# please do not add a target (like -cpp) as they will be added automatically\n' +
          '# (see gen-build-scripts.hxml and gen-build-static.hxml)');
    }

    updateProject(this.targetModule, this.version.MajorVersion + '.' + this.version.MinorVersion);

    if (!FileSystem.exists(this.outputDir)) FileSystem.createDirectory(this.outputDir);

    if (this.cppiaEnabled) {
      this.config.dce = DceNo;
    } else if (config.noStatic) {
      warn('`config.noStatic` is set to true, but cppia is disabled. Everything will still be compiled as static');
    }

    var teverything = timer('Haxe setup (all compilation times included)');
    if (Sys.systemName() != 'Windows' && Sys.getEnv('PATH').indexOf('/usr/local/bin') < 0) {
      Sys.putEnv('PATH', Sys.getEnv('PATH') + ":/usr/local/bin");
    }

    // check if haxe compiler / sources are present
    var hasHaxe = call('haxe', ['-version'], false) == 0;

    if (hasHaxe)
    {
#if !UE_SKIP_BAKE
      if (this.config.generateExterns) {
        this.generateExterns();
      }

      var ret = this.bakeExterns();
#else
      trace('Skipping bake externs');
      var ret = 0;
#end
      // compile static
      if (ret == 0)
      {
#if UE_CPPIA_RECOMPILE
        var targetStamp = '${this.outputDir}/Data/compiled.txt';
        var needsStatic = checkRecursive(targetStamp, [
            '$haxeDir/Generated/$externsFolder',
            '${data.pluginDir}/Haxe/Static',
          ].concat(this.modulePaths), true);
        if (needsStatic) {
          ret = this.compileStatic();
        } else {
          if (compileCppia() != 0) {
            throw 'Cppia compilation failed. Please check the Output Log for more information';
          } else {
            return;
          }
        }
#else
        ret = compileStatic();
#end
      }
      if (ret != 0)
      {
        throw 'Haxe compilation failed';
      }

      // compile cppia
      if (this.cppiaEnabled) {
        var cppiaRet = compileCppia();
        if (cppiaRet != 0) {
          err('=============================');
          err('Cppia compilation failed');
          err('=============================');
        }
      }
    } else {
      warn("Haxe compiler was not found!");
    }
    teverything();
    if (this.config.disabled) {
      var gen = '$srcDir/Generated';
      if (FileSystem.exists(gen)) {
        InitPlugin.deleteRecursive(gen,true);
      }
      if (FileSystem.exists(this.outputStatic)) {
        FileSystem.deleteFile(this.outputStatic);
      }
    }

    // add the output static linked library
    if (this.config.disabled || !FileSystem.exists(this.outputStatic))
    {
      warn('Haxe support is disabled');
    } else {
      if (this.config.disableUObject) {
        this.definitions.push('UHX_NO_UOBJECT=1');
      }
    }
  }

  private function getProjectName() {
    return new Path(this.data.projectFile).file;
  }

  /**
    Adds the HaxeRuntime module to the game project if it isn't there, and updates
    the template files
   **/
  private function updateProject(targetModule:String, ver:String)
  {
    var proj = getProjectName();
    if (proj == null) throw 'Build failed';
    InitPlugin.updateProject(this.data.projectDir, this.haxeDir, this.data.pluginDir, proj, ver, this.data.targetType == Program, false, targetModule);
  }

  private function getEngineVersion(config:HaxeModuleConfig):{ MajorVersion:Int, MinorVersion:Int, PatchVersion:Null<Int> } {
    var engineDir = this.data.engineDir;
    if (FileSystem.exists('$engineDir/Build/Build.version')) {
      return haxe.Json.parse( sys.io.File.getContent('$engineDir/Build/Build.version') );
    } else if (config.engineVersion != null) {
      var vers = config.engineVersion.split('.');
      var ret = { MajorVersion:Std.parseInt(vers[0]), MinorVersion:Std.parseInt(vers[1]), PatchVersion:Std.parseInt(vers[2]) };
      if (ret.MajorVersion == null || ret.MinorVersion == null) {
        throw ('The engine version is not in the right pattern (Major.Minor.Patch)');
      }
      return ret;
    } else {
      throw ('The engine build version file at $engineDir/Build/Build.version could not be found, and neither was an overridden version set on the uhxconfig.local file');
    }
  }

  private static function setEnvs(envs:Map<String,String>):Map<String,String> {
    var oldEnvs = new Map();
    for (key in envs.keys()) {
      var old = Sys.getEnv(key);
      oldEnvs[key] = old == null ? "" : old;
      Sys.putEnv(key, envs[key]);
    }
    return oldEnvs;
  }

  private function createHxml(name:String, args:Array<String>) {
    var hxml = new StringBuf();
    hxml.add('# this file is here for convenience only (e.g. to make your IDE work or to compile without invoking UE4 Build)\n');
    hxml.add('# this is not used by the build pipeline, and is recommended to be ignored by your SCM\n');
    hxml.add('# please change "arguments.hxml" instead\n\n');
    var i = -1;
    for (arg in args)
      hxml.add(arg + '\n');
    File.saveContent('$haxeDir/gen-$name.hxml', hxml.toString());
  }

  private function compileSources(args:Array<String>, ?realOutput:String)
  {
    var cmdArgs = [];
    for (arg in args) {
      if (arg == '' || arg.charCodeAt(0) == '#'.code) continue;

      if (arg.charCodeAt(0) == '-'.code) {
        var idx = arg.indexOf(' ');
        if (idx > 0) {
          var cmd = arg.substr(0,idx);
          cmdArgs.push(cmd);
          if (cmd == '-cpp' && realOutput != null)
            cmdArgs.push(realOutput);
          else
            cmdArgs.push(arg.substr(idx+1));
          continue;
        }
      }
      cmdArgs.push(arg);
    }
    cmdArgs = ['--cwd', haxeDir].concat(cmdArgs);
    if (this.config.enableTimers) {
      cmdArgs.push('--times');
      cmdArgs.push('-D');
      cmdArgs.push('macro_times');
    }

    return call('haxe', cmdArgs, true);
  }

  private function getModules(name:String, modules:Array<String>)
  {
    function recurse(path:String, pack:String)
    {
      if (pack == 'uhx.' || pack == 'unreal.') return;
      for (file in FileSystem.readDirectory(path))
      {
        if (file.toLowerCase().endsWith('.hx'))
          modules.push(pack + file.substr(0,-3));
        else if (FileSystem.isDirectory('$path/$file'))
          recurse('$path/$file', pack + file + '.');
      }
    }

    var game = '${data.projectDir}/Haxe/$name';
    if (FileSystem.exists(game)) recurse(game, '');
    var templ = '${data.pluginDir}/Haxe/$name';
    if (FileSystem.exists(templ)) recurse(templ, '');
  }

  private function call(program:String, args:Array<String>, showErrors:Bool)
  {
    log('$program ${args.join(' ')}');
    return Sys.command(program, args);
  }

  public function haxelibPath(name:String):String
  {
    try
    {
      var haxelib = new sys.io.Process('haxelib',['path', name]);
      var found = null;
      if (haxelib.exitCode() == 0)
      {
        for (ln in haxelib.stdout.readAll().toString().split('\n'))
        {
          if (FileSystem.exists(ln))
          {
            found = ln;
            break;
          }
        }
        if (found == null)
          err('Cannot find a valid path for haxelib path $name');
      } else {
        err('Error while calling haxelib path $name: ${haxelib.stderr.readAll()}');
      }
      haxelib.close();
      return found;
    }
    catch(e:Dynamic)
    {
      err('Error while calling haxelib path $name: $e');
      return null;
    }
  }

  private static function toMacroDef(arr:Array<String>):String {
    return '[' + [for (val in arr) '"' + val.replace('\\','/') + '"'].join(', ') + ']';
  }

  private function timer(name:String):Void->Void {
    if (!this.config.enableTimers)
      return function() {};
    var sw = Sys.time();
    return function() {
      var elapsed = Sys.time() - sw;
      log(' -> $name executed in ${elapsed}');
    }
  }
}
