package uhx.build;
import uhx.build.Log.*;
import sys.FileSystem;

class Main {
  static function main() {
#if !UE_POST_BUILD
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

    var ret = 0;

    try {
#if UE_BUILD_CS
    log('Building Haxe through the Build.cs file');
#elseif UE_PRE_BUILD
    log('Building Haxe through a pre-build script');
#elseif UE_EDITOR_COMPILE
    log('Building Haxe through the editor');
#end

      var data:UhxBuildData = {
        engineDir: haxe.macro.Compiler.getDefine("EngineDir"),
        projectDir: haxe.macro.Compiler.getDefine("ProjectDir"),
        targetName: haxe.macro.Compiler.getDefine("TargetName"),
        targetPlatform: haxe.macro.Compiler.getDefine("TargetPlatform"),
        targetConfiguration: haxe.macro.Compiler.getDefine("TargetConfiguration"),
        targetType: haxe.macro.Compiler.getDefine("TargetType"),
        projectFile: haxe.macro.Compiler.getDefine("ProjectFile"),
        pluginDir: haxe.macro.Compiler.getDefine("PluginDir"),
        rootDir: haxe.macro.Compiler.getDefine("RootDir"),

        skipBake: #if UE_SKIP_BAKE true #else false #end,
        cppiaRecompile: #if UE_CPPIA_RECOMPILE true #else false #end,
        ueEditorRecompile: #if UE_EDITOR_RECOMPILE true #else false #end,
        ueEditorCompile: #if UE_EDITOR_COMPILE true #else false #end,
      };

      // we're using #if conditionals for commands so that we only compile what's needed
#if Command
      var cmd =
      #if (Command == "GenerateProjectFiles")
        new GenerateProjectFiles(data);
      #else
        #error "Unknown Command"
      #end
      cmd.run();

#else
      var build = new UhxBaseBuild(data);

#if UE_PRE_BUILD
      if (!build.config.hooksEnabled)
      {
        log('Skipping pre-build script because hooks are disabled');
      }
      else if (Sys.getEnv("UE_SKIP_BUILD") == "1")
      {
        log("Skipping pre-build script because -SkipBuild was detected");
      }
      else
#end // UE_PRE_BUILD
      {
        build.run();
      }
#end // Command
    }
    catch(e:BuildError) {
      err('Build failed: ${e.msg}');
      ret = 1;
    }
    catch(e:Dynamic) {
#if UE_CPPIA_RECOMPILE
      err('Build failed: $e');
#else
      err('Build failed: $e\n${haxe.CallStack.toString(haxe.CallStack.exceptionStack())}');
#end
      ret = 1;
    }


    if (proc != null) {
      try {
        proc.kill();
      }
      catch(e:Dynamic) {
        err('Error while killing mspdbsrv: $e');
      }
    }

    Sys.exit(ret);

#else

    // We've disabled post-build scripts for now because they aren't doing anything
    // log('Running post-build script');
    // We aren't currently doing anything at post-build
#end // !UE_POST_BUILD
  }
}