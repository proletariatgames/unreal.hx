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
    var outputDir = this.data.projectDir + '/Intermediate/Haxe/${targetModule}-${data.targetPlatform}-${data.targetConfiguration}';
    if (shouldBuildEditor()) {
      outputDir += '-Editor';
    }

    return '$outputDir/$libName';
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

  private function generateExterns() {
    var baseManifest = data.pluginDir + '/Haxe/BuildTool/UHT/UE' + this.version.MajorVersion + '.' + this.version.MinorVersion + '.json';
    if (!FileSystem.exists(baseManifest)) {
      err('No prebuilt manifest found for version ${version.MajorVersion}.${version.MinorVersion}. Cannot generate externs');
      return;
    }
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

    var manifest:UhtManifest = haxe.Json.parse(sys.io.File.getContent(baseManifest)),
        uhtDir = this.data.projectDir + '/Intermediate/Haxe/UHT';
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

    function expand(s:String) {
      return expandVariables(s, target);
    }
    for (mod in manifest.Modules) {
      mod.BaseDirectory = expandVariables(mod.BaseDirectory, target);
      mod.IncludeBase = expandVariables(mod.IncludeBase, target);
      mod.OutputDirectory = expandVariables(mod.OutputDirectory, target);
      mod.PCH = expandVariables(mod.PCH, target);
      mod.GeneratedCPPFilenameBase = expandVariables(mod.GeneratedCPPFilenameBase, target);
      mod.ClassesHeaders = mod.ClassesHeaders.map(expand);
      mod.PublicHeaders = mod.PublicHeaders.map(expand);
      mod.PrivateHeaders = mod.PrivateHeaders.map(expand);
      mod.SaveExportedHeaders = false;
    }

    var targets = [{ name:this.targetModule, path:this.srcDir }];
    for (target in targets) {
      var headers = [];
      collectUhtHeaders(target.path, headers);
      manifest.Modules.push({
        Name: target.name,
        ModuleType: 'GameRuntime',
        BaseDirectory: target.path,
        IncludeBase: target.path,
        OutputDirectory: uhtDir,
        ClassesHeaders: [],
        PublicHeaders: headers,
        PrivateHeaders: [],
        PCH: "",
        GeneratedCPPFilenameBase: uhtDir + '/' + target.name + '.generated',
        SaveExportedHeaders: false,
        UHTGeneratedCodeVersion: 'None'
      });
    }

    sys.io.File.saveContent(uhtDir + '/externs.uhtmanifest', haxe.Json.stringify(manifest));
    // Call UHT
    var oldEnvs = setEnvs([
      'GENERATE_EXTERNS' => '1',
      'EXTERN_MODULES' => [ for (target in targets) target.name ].join(','),
      'EXTERN_OUTPUT_DIR' => this.data.projectDir
    ]);
    var args = [this.data.projectFile,'$uhtDir/externs.uhtmanifest', '-PLUGIN=UnrealHxGenerator', '-Unattended', '-stdout'];
    if (config.verbose) {
      args.push('-AllowStdOutLogVerbosity');
    }

    if (this.callUHT(args) != 0) {
      throw 'UHT call failed';
    }
    if (oldEnvs != null) {
      setEnvs(oldEnvs);
    }
  }

  private static function collectUhtHeaders(dir:String, arr:Array<String>, recurse=true) {
    for (file in FileSystem.readDirectory(dir)) {
      var path = '$dir/$file';
      if (file.endsWith('.h')) {
        if (sys.io.File.getContent(path).indexOf('${file.substr(0,file.length-2)}.generated.h') >= 0) {
          arr.push(path);
        }
      } else if (recurse && FileSystem.isDirectory(path)) {
        collectUhtHeaders(path, arr, file == 'Generated');
      }
    }
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

  public function run()
  {
    var engineVer = this.version;
    var defineVer = 'UE_VER=${engineVer.MajorVersion}.${engineVer.MinorVersion}',
        definePatch = 'UE_PATCH=${engineVer.PatchVersion == null ? 0 : engineVer.PatchVersion}';

    if (srcDir == null) {
      throw 'Build failed';
    }

    updateProject(targetModule, engineVer.MajorVersion + '.' + engineVer.MinorVersion);

    var outputStatic = getLibLocation(),
        outputDir = haxe.io.Path.directory(outputStatic);
    if (!FileSystem.exists(outputDir)) FileSystem.createDirectory(outputDir);

    var cppiaEnabled = shouldCompileCppia();
    if (cppiaEnabled) {
      this.config.dce = DceNo;
    } else if (config.noStatic) {
      warn('`config.noStatic` is set to true, but cppia is disabled. Everything will still be compiled as static');
    }

    // try to compile haxe if we have Haxe installed
    var debugSymbols = data.targetConfiguration != Shipping && config.noDebug != true;
    if (config.noDebug == false) {
      debugSymbols = true;
    }

    var teverything = timer('Haxe setup (all compilation times included)');
    if (Sys.systemName() != 'Windows' && Sys.getEnv('PATH').indexOf('/usr/local/bin') < 0) {
      Sys.putEnv('PATH', Sys.getEnv('PATH') + ":/usr/local/bin");
    }

    // check if haxe compiler / sources are present
    var hasHaxe = call('haxe', ['-version'], false) == 0;

    if (hasHaxe)
    {
      if (this.config.generateExterns) {
        this.generateExterns();
      }
      var compserver = Sys.getEnv("HAXE_COMPILATION_SERVER");
      if (compserver == null) {
        compserver = Sys.getEnv("HAXE_COMPILATION_SERVER_DEFER");
      }
      if (compserver != null) {
        Sys.putEnv("HAXE_COMPILATION_SERVER", null);
      }

      // Windows paths have '\' which needs to be escaped for macro arguments
      var escapedPluginPath = data.pluginDir.replace('\\','\\\\');
      var escapedHaxeDir = haxeDir.replace('\\','\\\\');
      var forceCreateExterns = this.config.forceBakeExterns == null ? Sys.getEnv('BAKE_EXTERNS') != null : this.config.forceBakeExterns;

      var ueExternDir = 'UE${engineVer.MajorVersion}.${engineVer.MinorVersion}.${engineVer.PatchVersion}';
      if (!FileSystem.exists('${data.pluginDir}/Haxe/Externs/$ueExternDir')) {
        ueExternDir = 'UE${engineVer.MajorVersion}.${engineVer.MinorVersion}';
        if (!FileSystem.exists('${data.pluginDir}/Haxe/Externs/$ueExternDir')) {
          throw ('Cannot find an externs directory for the unreal version ${engineVer.MajorVersion}.${engineVer.MinorVersion}');
        }
      }
      var externsFolder = shouldBuildEditor() ? 'Externs_Editor' : 'Externs';
      var bakeArgs = [
        '# this pass will bake the extern type definitions into glue code',
        FileSystem.exists('$haxeDir/baker-arguments.hxml') ? 'baker-arguments.hxml' : '',
        '-cp ${data.pluginDir}/Haxe/Static',
        '-D use-rtti-doc', // we want the documentation to be persisted
        '-D bake-externs',
        '-D $defineVer',
        '-D $definePatch',
        '',
        '-cpp $haxeDir/Generated/$externsFolder',
        '--no-output', // don't generate cpp files; just execute our macro
        '--macro uhx.compiletime.main.ExternBaker.process(["$escapedPluginPath/Haxe/Externs/Common", "$escapedPluginPath/Haxe/Externs/$ueExternDir", "$escapedHaxeDir/Externs"], $forceCreateExterns)'
      ];
      if (shouldBuildEditor()) {
        bakeArgs.push('-D WITH_EDITOR');
      }
      if (data.targetConfiguration == Shipping) {
        bakeArgs.push('-D UE_BUILD_SHIPPING');
      }
      if (data.targetConfiguration == Shipping) {
        bakeArgs.push('-D UE_PROGRAM');
      }
      if (this.config.disableUObject) {
        bakeArgs.push('-D UHX_NO_UOBJECT');
      }

      trace('baking externs');
      var tbake = timer('bake externs');
      var ret = compileSources(bakeArgs);
      tbake();
      this.createHxml('bake-externs', bakeArgs);

      // get all modules that need to be compiled
      var modulePaths = ['$haxeDir/Static'],
          scriptPaths = ['$haxeDir/Scripts'];
      if (this.config.extraStaticClasspaths != null) {
        modulePaths = modulePaths.concat(this.config.extraStaticClasspaths);
      }
      if (this.config.extraScriptClasspaths != null) {
        scriptPaths = scriptPaths.concat(this.config.extraScriptClasspaths);
      }
      if (this.config.noStatic) {
        scriptPaths = modulePaths.concat(scriptPaths);
        modulePaths = [];
      }
      if (!cppiaEnabled) {
        modulePaths = modulePaths.concat(scriptPaths);
        scriptPaths = [];
      }

      var curSourcePath = this.srcDir;
      var cps = null;
      var targetDir = '$outputDir/Static';

      // compile static
      if (ret == 0)
      {
        var curStamp:Null<Date> = null;
        if (FileSystem.exists(outputStatic)) {
          curStamp = FileSystem.stat(outputStatic).mtime;
        }

        trace('compiling Haxe');
        if (!FileSystem.exists(targetDir)) FileSystem.createDirectory(targetDir);

        cps = [
          'arguments.hxml',
          '-cp $haxeDir/Generated/$externsFolder',
          '-cp ${data.pluginDir}/Haxe/Static',
        ];
        for (path in modulePaths) {
          cps.push('-cp $path');
        }

        var args = cps.concat([
          '',
          '-main UnrealInit',
          '',
          '-D static_link',
          '-D destination=$outputStatic',
          '-D haxe_runtime_dir=$curSourcePath',
          '-D bake_dir=$haxeDir/Generated/$externsFolder',
          '-D HXCPP_DLL_EXPORT',
          '-D $defineVer',
          '-D $definePatch',

          '-cpp $targetDir/Built',
          '--macro uhx.compiletime.main.CreateGlue.run(' +toMacroDef(modulePaths) +', ' + toMacroDef(scriptPaths) + ')',
        ]);
        if (!FileSystem.exists('$targetDir/Built/Data')) {
          FileSystem.createDirectory('$targetDir/Built/Data');
        }
        if (!FileSystem.exists('$targetDir/Built/toolchain')) {
          FileSystem.createDirectory('$targetDir/Built/toolchain');
        }
        for (file in FileSystem.readDirectory('${data.pluginDir}/Haxe/BuildTool/toolchain')) {
          File.saveBytes('$targetDir/Built/toolchain/$file', File.getBytes('${data.pluginDir}/Haxe/BuildTool/toolchain/$file'));
        }

        if (shouldBuildEditor()) {
          args.push('-D WITH_EDITOR');
        }
        if (data.targetConfiguration == Shipping) {
          args.push('-D UE_BUILD_SHIPPING');
        }
        if (data.targetType == Program) {
          args.push('-D UE_PROGRAM');
        }
        if (this.config.disableUObject || data.targetType == Program) {
          args.push('-D UHX_NO_UOBJECT');
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
        if (cppiaEnabled) {
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

        if (compserver != null) {
          File.saveContent('$targetDir/Built/Data/compserver.txt','1');
          Sys.putEnv("HAXE_COMPILATION_SERVER", compserver);
        } else {
          File.saveContent('$targetDir/Built/Data/compserver.txt','0');
        }

        var thaxe = timer('Haxe compilation');
        ret = compileSources(args);
        thaxe();
        if (!isCrossCompiling) {
          this.createHxml('build-static', args);
          var complArgs = ['--cwd $haxeDir', '--no-output'].concat(args);
          this.createHxml('compl-static', complArgs.filter(function(v) return !v.startsWith('--macro')));
        }

        if (oldEnvs != null) {
          setEnvs(oldEnvs);
        }
        if (compserver != null) {
          Sys.putEnv("HAXE_COMPILATION_SERVER", null);
        }

        if (ret == 0 && isCrossCompiling) {
          // somehow -D destination doesn't do anything when cross compiling
          var hxcppDestination = '$targetDir/Built/libUnrealInit';
          if (debugSymbols) {
            hxcppDestination += '-debug.a';
          } else {
            hxcppDestination += '.a';
          }

          var shouldCopy =
            !FileSystem.exists(outputStatic) ||
            (FileSystem.exists(hxcppDestination) &&
             FileSystem.stat(hxcppDestination).mtime.getTime() > FileSystem.stat(outputStatic).mtime.getTime());
          if (shouldCopy) {
            File.saveBytes(outputStatic, File.getBytes(hxcppDestination));
          }
        }
        // if (ret == 0 && (curStamp == null || FileSystem.stat(outputStatic).mtime.getTime() > curStamp.getTime()))
        // {
        //   // HACK: there seems to be no way to add the .hx files as dependencies
        //   //       for this project. The PrerequisiteItems variable from Action is the one
        //   //       that keeps track of dependencies - and it cannot be set anywhere. Additionally -
        //   //       what it seems to be a bug - UE4 doesn't track the timestamps for the files it is
        //   //       linking against.
        //   //       This leaves little option but to meddle with actual sources' timestamps.
        //   //       It seems that a better least intrusive hack would be to meddle with the
        //   //       output library file timestamp. However, it's not possible to reliably find
        //   //       the output file name at this stage
        //
        //   var dep = '${data.projectDir}/Source/$targetModule/Generated/HaxeInit.cpp';
        //   // touch the file
        //   // it seems we only need this for UE 4.8
        //   File.saveContent(dep, File.getContent(dep));
        // }
      }
      if (ret != 0)
      {
        throw ('Haxe compilation failed');
      }

      // compile cppia
      if (cppiaEnabled) {
        for (module in scriptPaths) {
          cps.push('-cp $module');
        }

        var args = cps.concat([
            '',
            '-main UnrealCppia',
            '',
            '-D cppia',
            '-D $defineVer',
            '-D $definePatch',
            '-D ustatic_target=$targetDir/Built',
            '-cppia ${data.projectDir}/Binaries/Haxe/game.cppia',
            '--macro uhx.compiletime.main.CreateCppia.run(' +toMacroDef(modulePaths) +', ' + toMacroDef(scriptPaths) + ',' + (config.cppiaModuleExclude == null ? 'null' : toMacroDef(config.cppiaModuleExclude)) + ')',
        ]);
        if (debugSymbols) {
          args.push('-debug');
        }
        if (shouldBuildEditor()) {
          args.push('-D WITH_EDITOR');
        }
        if (data.targetConfiguration == Shipping) {
          args.push('-D UE_BUILD_SHIPPING');
        }
        if (config.extraCppiaCompileArgs != null)
          args = args.concat(config.extraCppiaCompileArgs);

        if (!FileSystem.exists('${data.projectDir}/Binaries/Haxe')) {
          FileSystem.createDirectory('${data.projectDir}/Binaries/Haxe');
        }

        var tcppia = timer('Cppia compilation');
        var cppiaRet = compileSources(args);
        tcppia();
        this.createHxml('build-script', args);
        var complArgs = ['--cwd ${data.projectDir}/Haxe', '--no-output'].concat(args);
        this.createHxml('compl-script', complArgs.filter(function(v) return !v.startsWith('--macro')));
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
      if (FileSystem.exists(outputStatic)) {
        FileSystem.deleteFile(outputStatic);
      }
    }

    // add the output static linked library
    if (this.config.disabled || !FileSystem.exists(outputStatic))
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
      if (old != null) {
        oldEnvs[key] = old;
      }
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
    args.push('-D BUILDTOOL_VERSION_LEVEL=$VERSION_LEVEL');

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
        if (file.endsWith('.hx'))
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
