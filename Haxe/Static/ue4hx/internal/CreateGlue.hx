package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;

using StringTools;

/**
  This command takes care of compiling all the files in the Static folders and generating the glue code as needed.
  It should be called as a `--macro` command-line option.
 **/
class CreateGlue {
  static var firstCompilation = true;
  static var hasRun = false;

  public static function run(alwaysCompilePaths:Array<String>) {
    // get all types that need to be compiled recursively
    var toCompile = [];
    for (path in alwaysCompilePaths) {
      getModules(path, toCompile);
    }
    if (toCompile.length == 0)
      toCompile.push('UnrealInit');

    registerMacroCalls();

    var modules = [ for (module in toCompile) Context.getModule(module) ];

    // once we get here, we've built everything we need
    var cur = Globals.cur;

    // main build loop. all build-sensitive types are here
    while (
      cur.uextensions != null ||
      cur.gluesToGenerate != null
    ) {

      var uextensions = cur.uextensions;
      cur.uextensions = null;
      while (uextensions != null) {
        var uext = uextensions.value;
        uextensions = uextensions.next;
        var type = Context.getType(uext);
        new BuildUExtension().generate(type);
      }

      var glues = cur.gluesToGenerate;
      cur.gluesToGenerate = null;
      while (glues != null) {
        var glue = glues.value;
        glues = glues.next;

        var type = Context.getType(glue);
      }
    }
  }

  private static function getModules(path:String, modules:Array<String>)
  {
    function recurse(path:String, pack:String)
    {
      if (pack == 'ue4hx.' || pack == 'unreal.') return;
      for (file in FileSystem.readDirectory(path))
      {
        if (file.endsWith('.hx'))
          modules.push(pack + file.substr(0,-3));
        else if (FileSystem.isDirectory('$path/$file'))
          recurse('$path/$file', pack + file + '.');
      }
    }

    if (FileSystem.exists(path)) recurse(path, '');
  }

  /**
    Registers onGenerate handler once per compilation
   **/
  private static function registerMacroCalls() {
    if (hasRun) return;
    hasRun = true;
    if (firstCompilation) {
      firstCompilation = false;
      Context.onMacroContextReused(function() {
        trace('reusing macro context');
        hasRun = false;
        return true;
      });
    }
    Globals.reset();
    Globals.cur.setHaxeRuntimeDir();
    var nativeGlue = new NativeGlueCode();
    Context.onGenerate( function(gen) nativeGlue.onGenerate(gen) );
    // seems like Haxe macro interpreter has a problem with void member closures,
    // so we need this function definition
    Context.onAfterGenerate( function() nativeGlue.onAfterGenerate() );
    haxe.macro.Compiler.include('unreal.helpers');
  }
}
