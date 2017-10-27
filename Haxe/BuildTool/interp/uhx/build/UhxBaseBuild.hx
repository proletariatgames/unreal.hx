package uhx.build;
import uhx.build.Log.*;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class UhxBaseBuild {
  public var data(default, null):UhxBuildData;
  public var config(default, null):UhxBuildConfig;
  var hadUhxErr:Bool;

  public function new(data:UhxBuildData, ?config:UhxBuildConfig) {
    for (field in Reflect.fields(data)) {
      if (Reflect.field(data, field) == null) {
        var f = field.substr(0,1).toUpperCase() + field.substr(1);
        throw new BuildError('Cannot find property $f');
      }
    }

    this.data = data;
    this.config = config == null ? getConfig() : config;
  }

  public function run() {
#if !cpp
    if (!config.interp) {
      var tbuilder = timer('uhx builder');
      if (checkOrBuildBuilder()) {
        var ret = this.callBuilder();
        tbuilder();
        if (ret != 0) {
          throw new BuildError('Build failed');
        }
      } else {
        tbuilder();
        throw new BuildError('C++ UhxBuild build failed');
      }
    }
#end
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

  private function checkOrBuildBuilder() {
    var dir = getBuilderDir();
    var name = getBuilderName();
    var path = dir + '/' + name;
    var shouldBuild = !FileSystem.exists(path);
    if (!shouldBuild) {
      var stamp = getNewerStampRec([this.data.pluginDir + '/Haxe/BuildTool/interp', this.data.pluginDir + '/Haxe/BuildTool/src']),
          curStamp = FileSystem.stat(path).mtime.getTime();
      shouldBuild = curStamp < stamp;
    }
    if (shouldBuild) {
      var args = [
        '-cpp', dir,
        '-D','destination=$path',
        '-cp', this.data.pluginDir + '/Haxe/BuildTool/interp',
        '-cp', this.data.pluginDir + '/Haxe/BuildTool/src',
        '-cp', this.data.pluginDir,
        '-main', 'uhx.build.CompiledMain',
      ];
      if (config.verbose) {
        args.push('-debug');
      }
      var ret = callHaxe(args, true);
      if (ret != 0) {
        err('UhxBuild build failed');
        return false;
      }
    }
    return true;
  }

  private function getBuilderDir() {
    return this.data.projectDir + '/Intermediate/Haxe/UhxBuild';
  }

  private function getBuilderName() {
    if (Sys.systemName() == "Windows") {
      return 'UhxBuild.exe';
    } else {
      return 'UhxBuild';
    }
  }

  private function callBuilder() {
    var dir = getBuilderDir();
    var name = getBuilderName();
    var path = dir + '/' + name;
    var args = [];
    makeArgsFromObj(this.data, args);
    makeArgsFromObj(this.config, args);
    return this.call(path, args, true);
  }

  static function makeArgsFromObj(obj:Dynamic, out:Array<String>) {
    for (field in Reflect.fields(obj)) {
      out.push('$field=${Reflect.field(obj,field)}');
    }
  }

  private function callHaxe(args:Array<String>, showErrors:Bool) {
    var cmd = 'haxe';
    var installPath = this.config.haxeInstallPath;
    if (installPath != null) {
      if (!haxe.io.Path.isAbsolute(installPath)) {
        installPath = this.data.projectDir + '/' + installPath;
      }
      if (Sys.systemName() == 'Windows') {
        cmd = '${installPath}/haxe.exe';
      } else {
        cmd = '${installPath}/haxe';
      }
      if (!FileSystem.exists(cmd)) {
        err('File "$cmd" does not exist');
        return -1;
      }
      Sys.putEnv('HAXEPATH', installPath);
    }

    var haxelibPath = this.config.haxelibPath;
    if (haxelibPath != null) {
      if (!haxe.io.Path.isAbsolute(haxelibPath)) {
        haxelibPath = this.data.projectDir + '/' + haxelibPath;
      }
      Sys.putEnv('HAXELIB_PATH', haxelibPath);
    }

#if cpp
    log('$cmd ${args.join(' ')}');
    if (showErrors) {
      return this.call(cmd,args,showErrors);
    }
    try {
      var proc = new sys.io.Process(cmd, args),
          err = Sys.stderr(),
          stdout = proc.stdout;
      var finishLock = new cpp.vm.Lock();
      cpp.vm.Thread.create(function() {
        try {
          while(true) {
            Sys.println(stdout.readLine());
          }
        }
        catch(e:haxe.io.Eof) {
        }
        finishLock.release();
      });

      var stderr = proc.stderr;
      try {
        while(true) {
          var ln = stderr.readLine();
          if (ln.indexOf('UHXERR:') >= 0) {
            this.hadUhxErr = true;
            if (showErrors) {
              err.writeString(ln);
              err.writeByte('\n'.code);
            }
          } else {
            err.writeString(ln);
            err.writeByte('\n'.code);
          }
        }
      }
      catch(e:haxe.io.Eof) {
      }

      finishLock.wait();
      return proc.exitCode();
    }
    catch(e:Dynamic) {
      return -1;
    }
#else
    return call(cmd, args, showErrors);
#end
  }

  private function call(program:String, args:Array<String>, showErrors:Bool)
  {
    log('$program ${args.join(' ')}');
    return Sys.command(program, args);
  }

  private function getConfig():UhxBuildConfig {
    var base:UhxBuildConfig = {};
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
#if !cpp
    if (haxe.macro.Compiler.getDefine("haxeInstallPath") != null) {
      base.haxeInstallPath = haxe.macro.Compiler.getDefine("haxeInstallPath");
    }
    if (haxe.macro.Compiler.getDefine("haxelibPath") != null) {
      base.haxelibPath = haxe.macro.Compiler.getDefine("haxelibPath");
    }
    if (haxe.macro.Compiler.getDefine("noDynamicObjects") != null) {
      base.noDynamicObjects = true;
    }
#end

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

    if (base.numProcessors == null) {
      base.numProcessors = getNumberOfProcesses();
    }

    for (fn in ConfigHelper.getConfigs()) {
      base = fn(this.data, base);
    }

    return base;
  }

  // adapted from hxcpp code
  public static function getNumberOfProcesses():Int
  {
    inline function runProc(cmd:String, args:Array<String>):Null<String> {
      try {
        var proc = new sys.io.Process(cmd, args);
        var ret = proc.stdout.readAll();
        if (proc.exitCode() != 0) {
          return null;
        }
        return ret.toString();
      } catch(e:Dynamic) {
        return null;
      }
    }
    var result = null;
    var sysName = Sys.systemName();
    if (sysName == "Windows")
    {
      var env = Sys.getEnv("NUMBER_OF_PROCESSORS");
      if (env != null)
      {
        result = env;
      }
    }
    else if (sysName == "Linux")
    {
      result = runProc("nproc", []);
      if (result == null)
      {
        var cpuinfo = runProc("cat", [ "/proc/cpuinfo" ]);
        if (cpuinfo != null)
        {
          var split = cpuinfo.split("processor");
          result = Std.string(split.length - 1);
        }
      }
    }
    else if (sysName == "Mac")
    {
      var cores = ~/Total Number of Cores: (\d+)/;
      var output = runProc("/usr/sbin/system_profiler", [ "-detailLevel", "full", "SPHardwareDataType" ]);
      if (cores.match(output))
      {
        result = cores.matched(1);
      }
    }

    if (result == null || Std.parseInt(result) < 1)
    {
      return 1;
    }
    else
    {
      return Std.parseInt(result);
    }
  }

private function getNewerStampRec(dirs:Array<String>):Float {
  var stamp = .0,
      newerFile = null;

  inline function checkFile(path:String) {
    var curStamp = FileSystem.stat(path).mtime.getTime();
    if (curStamp > stamp) {
      stamp = curStamp;

      newerFile = path;
    }
  }

  function recurse(dir:String) {
    for (file in FileSystem.readDirectory(dir)) {
      if (file.endsWith('.hx')) {
        checkFile('$dir/$file');
      } else if (FileSystem.isDirectory('$dir/$file')) {
        recurse('$dir/$file');
      }
    }
  }

  for (dir in dirs) {
    if (FileSystem.exists(dir)) {
      recurse(dir);
    }
  }

  if (config.verbose) {
    log('newer file found at $newerFile (${Date.fromTime(stamp)})');
  }
  return stamp;
}

}
