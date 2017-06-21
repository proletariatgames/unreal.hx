package uhx.build;
import uhx.build.Log.*;
import sys.FileSystem;

class Main {
  static function main() {
    var proc = null,
        pdbSrvPath = Sys.getEnv('VS140COMNTOOLS') + '/../IDE/mspdbsrv.exe';
    if (FileSystem.exists(pdbSrvPath)) {
      // workaround for https://github.com/HaxeFoundation/hxcpp/issues/600
      try {
        proc = new sys.io.Process(pdbSrvPath, ['-start']);
      }
      catch(e:Dynamic) {
        warn('Could not start mspdbsrv: $e');
      }
    }

    try {
      var build = new UhxBuild({
        engineDir: haxe.macro.Compiler.getDefine("EngineDir"),
        projectDir: haxe.macro.Compiler.getDefine("ProjectDir"),
        targetName: haxe.macro.Compiler.getDefine("TargetName"),
        targetPlatform: haxe.macro.Compiler.getDefine("TargetPlatform"),
        targetConfiguration: haxe.macro.Compiler.getDefine("TargetConfiguration"),
        targetType: haxe.macro.Compiler.getDefine("TargetType"),
        projectFile: haxe.macro.Compiler.getDefine("ProjectFile"),
        pluginDir: haxe.macro.Compiler.getDefine("PluginDir"),
      });
      build.run();
    }
    catch(e:Dynamic) {
      err('Uncaught exception: $e\n${haxe.CallStack.toString(haxe.CallStack.exceptionStack())}');
    }

    if (proc != null) {
      try {
        proc.kill();
      }
      catch(e:Dynamic) {
        err('Error while killing mspdbsrv: $e');
      }
    }
    trace('killed process');
  }
}
