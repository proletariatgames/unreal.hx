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

    var skipFile = haxe.macro.Compiler.getDefine("ProjectDir") + "/Intermediate/Haxe/skip",
        skipTxt = skipFile + '.txt',
        skipEditor = skipFile + '-editor.txt',
        ret = 0,
        shouldSkip = false;

    try {
      var file = skipTxt;
#if !UE_EDITOR_COMPILE
      if (FileSystem.exists(skipEditor)) {
        file = skipEditor;
      }
#end // UE_EDITOR_COMPILE

      // make sure to clean up the skip texts if this is an editor/ build.cs build
#if (UE_BUILD_CS || UE_EDITOR_COMPILE)
      if (FileSystem.exists(skipTxt)) {
        trace('The file $skipTxt was found while running this build');
        FileSystem.deleteFile(skipTxt);
      }
#else
      if (Sys.getEnv('COMPILING_WITH_BUILD_CS') != '1') {
        if (FileSystem.exists(skipTxt)) {
          trace('The file $skipTxt was found while running this build');
          FileSystem.deleteFile(skipTxt);
        }
      }
#end

#if UE_EDITOR_COMPILE
      if (FileSystem.exists(skipEditor)) {
        trace('$skipEditor file was still found, while running an editor compilation. Deleting');
        FileSystem.deleteFile(skipEditor);
      }
#end

      if (FileSystem.exists(file)) {
        var skip = StringTools.trim(sys.io.File.getContent(file));
        if (skip == "fail") {
          err('Haxe editor compilation failed');
          shouldSkip = true;
          ret = 2;
        } else {
          shouldSkip = true;
          log('Skipping Haxe compilation because it was already built');
        }
      }

      if (!shouldSkip) {
#if UE_BUILD_CS
    log('Building Haxe through the Build.cs file');
#elseif UE_PRE_BUILD
    log('Building Haxe through a pre-build script');
#elseif UE_EDITOR_COMPILE
    log('Building Haxe through the editor');
#end

        var build = new UhxBuild({
          engineDir: haxe.macro.Compiler.getDefine("EngineDir"),
          projectDir: haxe.macro.Compiler.getDefine("ProjectDir"),
          targetName: haxe.macro.Compiler.getDefine("TargetName"),
          targetPlatform: haxe.macro.Compiler.getDefine("TargetPlatform"),
          targetConfiguration: haxe.macro.Compiler.getDefine("TargetConfiguration"),
          targetType: haxe.macro.Compiler.getDefine("TargetType"),
          projectFile: haxe.macro.Compiler.getDefine("ProjectFile"),
          pluginDir: haxe.macro.Compiler.getDefine("PluginDir"),

          skipBake: #if UE_SKIP_BAKE true #else false #end,
          cppiaRecompile: #if UE_CPPIA_RECOMPILE true #else false #end,
        });

        build.run();
      }
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


#if UE_PRE_BUILD
    // if we are on the pre-build stage, make sure to delete any file that is still hanging there
    if (FileSystem.exists(skipTxt)) {
      FileSystem.deleteFile(skipTxt);
    }

    if (FileSystem.exists(skipEditor)) {
      FileSystem.deleteFile(skipEditor);
    }

#elseif UE_BUILD_CS
    if (!FileSystem.exists(skipEditor)) {
      if (ret == 0) {
        // if we are on the first stage, make sure we DO have a file so that we don't build twice
        sys.io.File.saveContent(skipTxt, "1");
      } else {
        sys.io.File.saveContent(skipTxt, "fail");
      }
    }
#end


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

    log('Running post-build script');
    var skipFile = haxe.macro.Compiler.getDefine("ProjectDir") + "/Intermediate/Haxe/skip",
        skipTxt = skipFile + '.txt',
        skipEditor = skipFile + '-editor.txt';
    // at post build, all we want to do is delete any skip file that is still there
    // this doesn't really matter much, as we'd already delete a skip.txt file on a normal pre-build call
    // and we'd delete a skip-editor.txt on the editor after the build is done. However, something unexpected might
    // happen - for example, the editor could be closed while compiling - which would make the editor file stick around
    if (FileSystem.exists(skipTxt)) {
      trace('The file $skipTxt still existed. Deleting');
      FileSystem.deleteFile(skipTxt);
    }

    if (FileSystem.exists(skipEditor)) {
      FileSystem.deleteFile(skipEditor);
    }
#end // !UE_POST_BUILD
  }
}
