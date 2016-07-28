package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;

using StringTools;
using Lambda;

/**
  This command takes care of compiling all the files in the Static folders and generating the glue code as needed.
  It should be called as a `--macro` command-line option.
 **/
class CreateGlue {
  static var firstCompilation = true;
  static var hasRun = false;
  static var lastScriptPaths:Array<String>;

  public static function run(alwaysCompilePaths:Array<String>, ?scriptPaths:Array<String>) {
    lastScriptPaths = scriptPaths;
    Globals.cur.checkBuildVersionLevel();
    registerMacroCalls();
    Globals.cur.checkOlderCache();

    // get all types that need to be compiled recursively
    var toCompile = [];
    for (path in alwaysCompilePaths) {
      getModules(path, toCompile);
    }
    toCompile.push('UnrealInit');
    if (!Context.defined('UHX_NO_UOBJECT')) {
      toCompile.push('unreal.ReflectAPI');
      toCompile.push('unreal.ByteArray');
    }
    var scriptModules = [];
    for (path in scriptPaths) {
      getModules(path, scriptModules);
    }
    Globals.cur.scriptModules = [ for (module in scriptModules) module => true ];

    var nativeGlue = new NativeGlueCode();

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
    var toGatherModules = [ for (module in scriptModules) Context.getModule(module) ];
    ensureCompiled(toGatherModules);

    Globals.cur.inScriptPass = false;

    // once we get here, we've built everything we need

    // main build loop. all build-sensitive types will be continously be built
    // until there's nothing else to be built
    var typesTouched = new Map(),
        running = false;
    var didProcess = false;
    Context.onAfterTyping(function(types) {
      if (types.exists(function(t) return Std.string(t) == 'TClassDecl(ue4hx.internal.CreateGlue)')) {
        return; // macro context
      }
      Globals.cur.hasUnprocessedTypes = false;
      while (true) {
        var cur = Globals.cur;
        for (type in types) {
          var str = Std.string(type);
          if (!typesTouched[str]) {
            typesTouched[str] = true;
            switch(type) {
            case TAbstract(a):
              var a = a.get();
              if (a.meta.has(':ueHasGenerics')) {
                cur.gluesToGenerate = cur.gluesToGenerate.add(TypeRef.fromBaseType(a, a.pos).getClassPath());
              }
            case _:
            }
          }
        }
        if (running) {
          return;
        }
        running = true;

        while (
          cur.uextensions != null ||
          cur.gluesToGenerate != null ||
          cur.delays != null) {

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
              if (cl.meta.has(':ueHasGenerics')) {
                new GenericFuncBuild().buildFunctions(c);
              }
            case TAbstract(a,_):
              var a = a.get();
              var cl = a.impl.get();
              if (a.meta.has(':ueHasGenerics')) {
                new GenericFuncBuild().buildFunctions(a.impl);
              }
            case _:
              throw 'assert';
            }
          }

          var delays = cur.delays;
          cur.delays = null;
          while (delays != null) {
            delays.value();
            delays = delays.next;
          }
        }

        if (cur.delays != null || cur.uextensions != null || cur.gluesToGenerate != null) {
          continue;
        }
        running = false;

        break;
      }
      if (!Globals.cur.hasUnprocessedTypes && !didProcess) {
        didProcess = true;

        while(Globals.cur.scriptGlues != null) {
          var scriptGlues = Globals.cur.scriptGlues;
          Globals.cur.scriptGlues = null;
          while (scriptGlues != null) {
            var scriptGlue = scriptGlues.value;
            scriptGlues = scriptGlues.next;
            ScriptGlue.generate(scriptGlue);
          }
        }

        // create hot reload helper
        if (Context.defined('WITH_CPPIA')) {
          LiveReloadBuild.bindFunctions('LiveReloadStatic');
          var lives = [ for (cls in Globals.liveReloadFuncs.keys()) cls ];
          if (lives.length > 0) {
            sys.io.File.saveContent( haxe.macro.Compiler.getOutput() + '/Data/livereload.txt', lives.join('\n') );
          }
        }
        Globals.cur.loadCachedTypes();
        Globals.cur.saveCachedBuilt();
      }

    });


    Context.onGenerate( function(gen) {
      // starting from now, we can't create new types
      Globals.cur.reserveCacheFile();
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
        // trace('macro context reused');
        hasRun = false;
        // we need to add these classpaths again
        // otherwise, the compilation server will not find the
        // source files and request a full recompilation of the script types
        if (lastScriptPaths != null) {
          for (path in lastScriptPaths) {
            haxe.macro.Compiler.addClassPath(path);
          }
        }
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
          if (c.meta.has(':ustatic')) {
            continue;
          }
          c.meta.remove(':native');
          if (Context.unify(type, uobj)) {
            c.meta.add(':native', [macro $v{'unreal.UObject'}], c.pos);
            c.meta.add(':include', [macro $v{'unreal/UObject.h'}], c.pos);
            c.exclude();
          } else if (Context.unify(type, ustruct)) {
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
