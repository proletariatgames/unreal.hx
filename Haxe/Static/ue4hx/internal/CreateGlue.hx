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
    Globals.cur.canCreateTypes = true;
    // get all types that need to be compiled recursively
    var toCompile = [];
    for (path in alwaysCompilePaths) {
      getModules(path, toCompile);
    }
    if (toCompile.length == 0)
      toCompile.push('UnrealInit');

    registerMacroCalls();
    Globals.cur.canCreateTypes = true;

    var modules = [ for (module in toCompile) Context.getModule(module) ];
    // make sure all fields have been typed
    for (module in modules) {
      for (type in module) {
        switch(Context.follow(type)) {
        case TInst(c,_):
          var cl = c.get();
          for (field in cl.fields.get())
            Context.follow(field.type);
          for (field in cl.statics.get())
            Context.follow(field.type);
          var ctor = cl.constructor;
          if (ctor != null)
            Context.follow(ctor.get().type);
        case TEnum(_):
          UEnumBuild.processEnum(type);
        case _:
        }
      }
    }

    // once we get here, we've built everything we need
    var cur = Globals.cur;

    var nativeGlue = new NativeGlueCode();

    // main build loop. all build-sensitive types will be continously be built
    // until there's nothing else to be built
    while (
      cur.uextensions != null ||
      cur.gluesToGenerate != null ||
      cur.typeParamsToBuild != null ||
      cur.typesWithTParams != null) {

      var uextensions = cur.uextensions;
      cur.uextensions = null;
      while (uextensions != null) {
        var uext = uextensions.value;
        uextensions = uextensions.next;
        var type = Context.getType(uext);
        new UExtensionBuild().generate(type);
      }

      var glues = cur.gluesToGenerate;
      cur.gluesToGenerate = null;
      while (glues != null) {
        var glue = glues.value;
        glues = glues.next;

        var type = Context.getType(glue);
        switch(type) {
        case TInst(c,_):
          var cl = c.get();
          if (cl.meta.has(':ueHasGenerics'))
            new GenericFuncBuild().buildFunctions(c);
          nativeGlue.writeGlueHeader(cl);
        case _:
          throw 'assert';
        }
      }

      var tparams = cur.typesWithTParams;
      cur.typesWithTParams = null;
      while (tparams != null) {
        var param = tparams.value;
        tparams = tparams.next;
        var type = Context.getType(param);
        TypeParamBuild.checkBuiltFields( type );
      }

      var params = cur.typeParamsToBuild;
      cur.typeParamsToBuild = null;
      while (params != null) {
        var param = params.value;
        params = params.next;
        TypeParamBuild.ensureTypesBuilt( param.base, param.args, param.pos );
      }
    }

    // starting from now, we can't create new types
    Globals.cur.canCreateTypes = false;
    Context.onGenerate( function(gen) { nativeGlue.onGenerate(gen); } );
    // seems like Haxe macro interpreter has a problem with void member closures,
    // so we need this function definition
    Context.onAfterGenerate( function() nativeGlue.onAfterGenerate() );
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
    haxe.macro.Compiler.include('unreal.helpers');
  }
}
