package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;

using StringTools;

class CreateCppia {
  static var firstCompilation = true;
  static var hasRun = false;

  public static function run(staticPaths:Array<String>, scriptPaths:Array<String>, ?excludeModules:Array<String>) {
    Globals.cur.checkBuildVersionLevel();
    registerMacroCalls();

    var statics = [];
    for (path in staticPaths) {
      getModules(path,statics);
    }

    Globals.cur.inScriptPass = true;
    var scripts = [];
    for (path in scriptPaths) {
      getModules(path,scripts);
    }
    Globals.cur.scriptModules = [ for (module in scripts) module => true ];
    var modules = [ for (module in scripts) Context.getModule(module) ];
    var target = Context.definedValue('ustatic_target');
    if (target != null && sys.FileSystem.exists('$target/Data/livereload.txt')) {
      var arr = [];
      for (type in sys.io.File.getContent('$target/Data/livereload.txt').split('\n')) {
        try {
          arr.push(Context.getType(type));
        }
        catch(e:Dynamic) {
          if (!Std.string(e).startsWith("Type not found '" + type)) {
            throw new Error(Std.string(e), Context.currentPos());
          }
        }
      }
      modules.push(arr);
    }
    ensureCompiled(modules);
    Globals.cur.inScriptPass = false;

    // create hot reload helper
    LiveReloadBuild.bindFunctions('LiveReloadScript');

    var blacklist = [
      'unreal.Wrapper',
      'haxe.Int64',
      'cpp.Int64',
      'Date',
      'unreal.Struct',
      'unreal.TemplateStruct',
      'unreal.POwnedPtr',
      'unreal.AnyPtr',
      'unreal.TArray',
      'unreal.ReflectAPI',
      'unreal.ByteArray',
      'unreal.AnyPtr',
      'unreal.ConstAnyPtr',
    ];

    addTimestamp();

    Context.onGenerate(function(types) {
      var allStatics = [ for (s in statics.concat(blacklist)) s => true ],
          incompleteExcludes = null;
      if (excludeModules != null) {
        for (m in excludeModules) {
          if (m.endsWith('.*')) {
            if (incompleteExcludes == null) incompleteExcludes = [];
            incompleteExcludes.push(m.substr(0,-1));
          } else {
            allStatics[m] = true;
          }
        }
      }
      inline function hasExclude(module:String) {
        if (allStatics[module]) {
          return true;
        } else if (incompleteExcludes != null) {
          var ret = false;
          for (exc in incompleteExcludes) {
            if (module.startsWith(exc)) {
              ret = true;
              break;
            }
          }
          return ret;
        } else {
          return module.startsWith('cpp.');
        }
      }
      for (type in types) {
        switch(type) {
          case TInst(_.get()=>c,_):
            if (hasExclude(c.module) || c.meta.has(':uextern') || c.meta.has(':coreApi')) {
              if (c.name != 'UnrealCppia') {
                c.exclude();
              }
            } else {
              switch(c.pack) {
              case ['unreal','helpers']:
                c.exclude();
              case _:
              }
            }
          case TEnum(_.get()=>e,_):
            if (hasExclude(e.module)) {
              e.exclude();
            }
          case TAbstract(_.get()=>a,_):
            if (hasExclude(a.module) || a.meta.has(':uextern') || a.meta.has(':coreApi')) {
              var impl = a.impl;
              if (impl != null) {
                impl.get().exclude();
              }
            }
          case _:
        }
      }
    });
  }

  private static function addTimestamp() {
    // adds a class that returns the timestamp of when it was built.
    // this works around HaxeFoundation/hxcpp#358 by adding logic that determines
    // whether the newly loaded script has the same timestamp as the older one
    var stamp = Date.now().getTime();
    var cls = macro class CppiaCompilation {
      @:keep public static var timestamp(default,null):Float = $v{stamp};
    };
    cls.pack = ['ue4hx','internal'];
    Globals.cur.hasUnprocessedTypes = true;
    Context.defineType(cls);
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

  private static function ensureCompiled(modules:Array<Array<Type>>) {
    var ustruct = Context.getType('unreal.Struct');
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
        case TAbstract(a,_):
          if (Context.unify(type, ustruct)) {
            a.get().impl.get().exclude();
            continue;
          }
        case _:
        }
      }
    }
  }

  private static function registerMacroCalls() {
    if (hasRun) return;
    hasRun = true;
    if (firstCompilation) {
      firstCompilation = false;
      Context.onMacroContextReused(function() {
        trace('macro context reused');
        hasRun = false;
        Globals.reset();
        return true;
      });
    }
    Globals.cur.setHaxeRuntimeDir();
    haxe.macro.Compiler.include('unreal.helpers');
  }
}
