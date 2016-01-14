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

  public static function run(alwaysCompilePaths:Array<String>, ?scriptPaths:Array<String>) {
    Globals.cur.checkBuildVersionLevel();
    registerMacroCalls();
    Globals.cur.checkOlderCache();

    Globals.cur.canCreateTypes = true;
    // get all types that need to be compiled recursively
    var toCompile = [];
    for (path in alwaysCompilePaths) {
      getModules(path, toCompile);
    }
    toCompile.push('UnrealInit');

    var nativeGlue = new NativeGlueCode();

    Globals.cur.canCreateTypes = true;
    var uinits = [];

    var modules = [ for (module in toCompile) Context.getModule(module) ];
    // make sure all fields have been typed
    ensureCompiled(modules);
    // make sure cppia classes are compiled as well
    for (path in scriptPaths) {
      // we only add classpaths after all static compilation so it is obvious that we cannot
      // reference script paths from static
      haxe.macro.Compiler.addClassPath(path);
    }
    Globals.cur.inScriptPass = true;
    var toGather = [];
    for (path in scriptPaths) {
      getModules(path, toGather);
    }
    var toGatherModules = [ for (module in toGather) Context.getModule(module) ];
    ensureCompiled(toGatherModules);

    Globals.cur.inScriptPass = false;

    // once we get here, we've built everything we need
    var cur = Globals.cur;

    // main build loop. all build-sensitive types will be continously be built
    // until there's nothing else to be built
    while (
      cur.uextensions != null ||
      cur.gluesToGenerate != null ||
      cur.typeParamsToBuild != null ||
      cur.typesThatNeedTParams != null) {

      var uextensions = cur.uextensions;
      cur.uextensions = null;
      while (uextensions != null) {
        var uext = uextensions.value;
        uextensions = uextensions.next;
        Globals.cur.currentFeature = 'keep';
        var type = Context.getType(uext);
        new UExtensionBuild().generate(type);
      }
      Globals.cur.currentFeature = null;

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

      var tparams = cur.typesThatNeedTParams;
      cur.typesThatNeedTParams = null;
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
        TypeParamBuild.ensureTypesBuilt( param.base, param.args, param.pos, param.feature );
      }
    }

    var isDceFull = Context.definedValue('dce') == 'full';
    for (key in Globals.cur.toDefineTParams.keys()) {
      var def = Globals.cur.toDefineTParams[key];
      var feats = Globals.cur.getDeps( key );
      if (feats != null && feats.length > 0) {
        if (feats[0] == 'keep') {
          def.meta.push({ name:':keep', params:[], pos:def.pos });
        } else {
          var params = [ for (feat in feats) macro $v{feat} ];
          def.meta.push({ name:':ifFeature', params:params, pos:def.pos });
          for (field in def.fields) {
            if (field.meta == null) field.meta = [];
            field.meta.push({ name:':ifFeature', params:params, pos:def.pos });
          }
        }
      }
      cur.cachedBuiltTypes.push( def.pack.join('.') + '.' + def.name );
      Context.defineType(def);
    }
    for (type in Globals.cur.scriptGlues) {
      ScriptGlue.generate(type);
      Globals.cur.cachedBuiltTypes.push(type);
    }

    // create hot reload helper
    if (Context.defined('WITH_CPPIA')) {
      LiveReloadBuild.bindFunctions('LiveReloadStatic');
    }
    Globals.cur.loadCachedTypes();
    Globals.cur.saveCachedBuilt();

    // starting from now, we can't create new types
    Globals.cur.canCreateTypes = false;
    Globals.cur.reserveCacheFile();
    Context.onGenerate( function(gen) {
      nativeGlue.onGenerate(gen);
      excludeModules(toGatherModules);
    });
    // seems like Haxe macro interpreter has a problem with void member closures,
    // so we need this function definition
    Context.onAfterGenerate( function() {
      nativeGlue.onAfterGenerate();
      Globals.cur.setCacheFile();
    });
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
        hasRun = false;
        Globals.reset();
        return true;
      });
    }
    Globals.cur.setHaxeRuntimeDir();
    haxe.macro.Compiler.include('unreal.helpers');
  }

  private static function excludeModules(modules:Array<Array<Type>>) {
    var uobj = Context.getType('unreal.UObject'),
        ustruct = Context.getType('unreal.Wrapper');
    for (module in modules) {
      for (type in module) {
        switch(Context.follow(type)) {
        case TInst(c,_):
          var c = c.get();
          c.meta.remove(':native');
          if (Context.unify(type, uobj)) {
            c.meta.add(':native', [macro $v{'unreal.UObject'}], c.pos);
            c.meta.add(':include', [macro $v{'unreal/UObject.h'}], c.pos);
            c.exclude();
          } else if (Context.unify(type, ustruct)) {
            Context.warning('There is no benefit in compiling this type as a script; It will be compiled as a Static instead', c.pos);
            // c.meta.add(':native', [macro $v{'unreal.Wrapper'}], c.pos);
            // c.meta.add(':include', [macro $v{'unreal/Wrapper.h'}], c.pos);
          } else {
            c.meta.add(':native', [macro $v{'Dynamic'}], c.pos);
            c.exclude();
          }
        case TEnum(e,_):
          var e = e.get();
          e.meta.remove(':native');
          e.meta.add(':native', [macro $v{'Dynamic'}], e.pos);
          e.exclude();
        case TAbstract(a,_):
          a.get().exclude();
        case _:
        }
      }
    }
  }

  private static function ensureCompiled(modules:Array<Array<Type>>) {
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
        case TEnum(e,_):
          var e = e.get();
          if (Globals.cur.inScriptPass && !e.isExtern) {
            e.meta.add(':uscript',[],e.pos);
          }
          UEnumBuild.processEnum(type);
        case TAbstract(a,_):
        case _:
        }
      }
    }
  }
}
