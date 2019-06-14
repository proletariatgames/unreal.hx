package uhx.compiletime.main;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import uhx.compiletime.tools.*;
import uhx.compiletime.types.*;

using StringTools;
using Lambda;
using uhx.compiletime.tools.MacroHelpers;

/**
  This command takes care of compiling all the files in the Static folders and generating the glue code as needed.
  It should be called as a `--macro` command-line option.
 **/
class CreateGlue {
  #if haxe4
  @:persistent
  #end
  static var firstCompilation = true;
  static var hasRun = false;
  static var lastScriptPaths:Array<String>;
  static var externsDir:String;

  public static function run(alwaysCompilePaths:Array<String>, ?scriptPaths:Array<String>) {
    lastScriptPaths = scriptPaths;
    Globals.cur.checkBuildVersionLevel();
    registerMacroCalls();
    Globals.cur.checkOlderCache();
    externsDir = Context.definedValue('UHX_BAKE_DIR');

    // get all types that need to be compiled recursively
    var staticModules = [],
        staticPaths = [];
    for (path in alwaysCompilePaths) {
      getModules(path, staticModules, staticPaths);
    }
    var toCompile = staticModules.concat(['UnrealInit']);
    if (!Context.defined('UHX_NO_UOBJECT')) {
      toCompile.push('unreal.ReflectAPI');
      toCompile.push('unreal.ByteArray');
    }
    var scriptModules = [];
    for (path in scriptPaths) {
      getModules(path, scriptModules);
    }
    Globals.cur.staticModules = [ for (module in staticModules) module => true ];

    var nativeGlue = new NativeGlueCode();

    var uinits = [];
    var modules = [ for (module in toCompile) Context.getModule(module) ];
    // make sure all fields have been typed
    keepEnums(modules);
    var scriptClassesAdded = scriptModules.length == 0;
    var toGatherModules = null;

    var fileDeps = new Map();
    for (path in staticPaths) {
      fileDeps[path] = true;
    }
    var cur = Globals.cur;
    inline function addFileDep(file:String, force:Bool, direct=true) {
      if (file != null && file.endsWith('.hx')) {
        if (!cur.inScriptPass || (force || file.startsWith(externsDir))) {
          fileDeps.set(file, direct);
        }
      }
    }

    // once we get here, we've built everything we need

    // main build loop. all build-sensitive types will be continously be built
    // until there's nothing else to be built
    var typesTouched = new Map(),
        running = false;
    var didProcess = false,
        finalized = false;
    Context.onAfterTyping(function(types) {
      if (types.exists(function(t) return Std.string(t) == 'TClassDecl(uhx.compiletime.main.CreateGlue)')) {
        return; // macro context
      }
      Globals.cur.hasUnprocessedTypes = false;
      for (type in types) {
        var str = Std.string(type);
        if (!typesTouched[str]) {
          typesTouched[str] = true;
          switch(type) {
          case TAbstract(a):
            var a = a.get();
            addFileDep(Context.getPosInfos(a.pos).file, false);
          case TClassDecl(c):
            var c = c.get();
            if (!c.meta.has(':scriptGlue')) {
              if (!cur.inScriptPass) {
                addFileDep(Context.getPosInfos(c.pos).file, true);
              } else if (!c.meta.has(':uextern') && c.meta.has(':uclass')) {
                addFileDep(Context.getPosInfos(c.pos).file, true, false);
              } else {
                addFileDep(Context.getPosInfos(c.pos).file, false);
              }
            }
          case TEnumDecl(e):
            var e = e.get();
            if (!cur.inScriptPass) {
              addFileDep(Context.getPosInfos(e.pos).file, true);
            } else if (!e.meta.has(':uextern') && e.meta.has(':uenum')) {
              addFileDep(Context.getPosInfos(e.pos).file, true, false);
            } else {
              addFileDep(Context.getPosInfos(e.pos).file, false);
            }
          case TTypeDecl(t):
            var t = t.get();
            if (!cur.inScriptPass) {
              addFileDep(Context.getPosInfos(t.pos).file, true);
            } else if (t.meta.has(':ustruct') || t.meta.has(':udelegate')) {
              addFileDep(Context.getPosInfos(t.pos).file, true, false);
            } else {
              addFileDep(Context.getPosInfos(t.pos).file, false);
            }
          case _:
          }
        }
      }

      while (true) {
        if (running) {
          return;
        }
        running = true;

        while (
          cur.uextensions != null ||
          cur.delays != null) {

          var uextensions = cur.uextensions;
          cur.uextensions = null;
          while (uextensions != null) {
            var uext = uextensions.value;
            uextensions = uextensions.next;
            var type = Context.getType(uext);
            new UExtensionBuild().generate(type);
          }

          var delays = cur.delays;
          cur.delays = null;
          while (delays != null) {
            delays.value();
            delays = delays.next;
          }
        }

        if (cur.delays != null || cur.uextensions != null) {
          continue;
        }
        running = false;

        break;
      }
      if (!Globals.cur.hasUnprocessedTypes) {
        if (!scriptClassesAdded) {
          Globals.cur.hasUnprocessedTypes = true;
          // make sure cppia classes are compiled as well
          for (path in scriptPaths) {
            // we only add classpaths after all static compilation so it is obvious that we cannot
            // reference script paths from static
            haxe.macro.Compiler.addClassPath(path);
          }
          Globals.cur.inScriptPass = true;
          toGatherModules = [ for (module in scriptModules) Context.getModule(module) ];
          keepEnums(toGatherModules);
          // ensureCompiled(toGatherModules);
          scriptClassesAdded = true;
        } else if (!didProcess) {
          Globals.cur.inScriptPass = false;
          var cur = Globals.cur;
          // we need generics processing to be the very last thing we do
          while (cur.gluesToGenerate != null) {
            var glues = cur.gluesToGenerate;
            cur.gluesToGenerate = null;
            while (glues != null) {
              var glue = glues.value;
              glues = glues.next;

              var type = Context.getType(glue);
              switch(type) {
              case TInst(c,_):
                var cl = c.get();
              case TAbstract(a,_):
                var a = a.get();
                var cl = a.impl.get();
              case _:
                throw 'assert';
              }
            }
          }
          didProcess = true;
          if (Globals.cur.hasUnprocessedTypes) {
            return; // this will still run again
          }
        }
        if (!didProcess) {
          return; // it will run again
        }

        while(Globals.cur.scriptGlues != null) {
          var scriptGlues = Globals.cur.scriptGlues;
          Globals.cur.scriptGlues = null;
          while (scriptGlues != null) {
            var scriptGlue = scriptGlues.value;
            scriptGlues = scriptGlues.next;
            ScriptGlue.generate(scriptGlue);
          }
        }
        if (Globals.cur.hasUnprocessedTypes) {
          return; // this will still run again
        }

        if (!finalized) {
          finalized = true;

          // create hot reload helper
          if (Context.defined('WITH_CPPIA')) {
            var lives = [ for (cls in Globals.cur.explicitLiveReloadFunctions.keys()) cls ];
            var out = Globals.cur.staticBaseDir + '/Data/livereload.txt';
            if (lives.length > 0) {
              Globals.cur.fs.saveContent( out, lives.join('\n') );
            } else if (Globals.cur.fs.exists(out)) {
              Globals.cur.fs.deleteFile(out);
            }
          }
          Globals.cur.loadCachedTypes();
          Globals.cur.saveCachedBuilt();
        }
      }
    });

    var builtGlues = [];
    Context.onGenerate( function(gen) {
      Globals.callGenerateHooks(gen);
      LiveReloadBuild.onGenerate(gen);
      if (Context.defined('WITH_CPPIA')) {
        MetaDefBuild.writeStaticDefs();
      }

      for (t in gen) {
        switch(t) {
        case TInst(c,_):
          var meta = c.get().meta;
          if (meta.has(':ugenerated')) {
            builtGlues.push({ path:c.toString(), glues:meta.extractStrings(':ugenerated'), isScript:meta.has(':uscript')});
          } else if (meta.has(':uclass')) {
            builtGlues.push({ path:c.toString(), glues:[], isScript:meta.has(':uscript') });
          } else if (meta.has(':buildXml')) {
            // sys.FileSystem has an uneeded @:buildXml call that ensures that the std library gets built, even if
            // we have overridden all the needed cpp.Native* classes
            switch(c.toString())
            {
              case 'sys.FileSystem':
                meta.remove(':buildXml');
              case _:
            }
          }
        case TAbstract(a,_):
          var impl = a.get().impl;
          if (impl != null) {
            var meta = impl.get().meta;
            if (meta.has(':ugenerated')) {
              var a = a.get();
              builtGlues.push({ path:impl.toString(), glues:meta.extractStrings(':ugenerated'), isScript:a.meta.has(':uscript') && !a.meta.has(':udelegate')});
            }
          }
        case TEnum(e,_):
          var meta = e.get().meta;
          if (meta.has(':ugenerated')) {
            builtGlues.push({ path:e.toString(), glues:meta.extractStrings(':ugenerated'), isScript:false });
          }
        case _:
        }
      }
      // starting from now, we can't create new types
      Globals.cur.reserveCacheFile();
      nativeGlue.onGenerate(gen);
      if (toGatherModules != null) {
        excludeModules(toGatherModules);
      }
    });
    // seems like Haxe macro interpreter has a problem with void member closures,
    // so we need this function definition
    Context.onAfterGenerate( function() {
      nativeGlue.onAfterGenerate();
      Globals.cur.setCacheFile();
      writeFileDeps(fileDeps, '${Globals.cur.staticBaseDir}/Data/staticDeps.txt');
      Globals.cur.fs.saveContent('${Globals.cur.staticBaseDir}/Data/staticModules.txt', staticModules.join('\n'));
      writeScriptGlues(builtGlues, '${Globals.cur.staticBaseDir}/Data/scriptGlues.txt');
      uhx.compiletime.LiveReloadBuild.saveLiveHashes('static-live-hashes.txt');
    });
  }

  private static function writeScriptGlues(builtGlues:Array<{ path:String, glues:Array<String>, isScript:Bool }>, file:String) {
    var ret = sys.io.File.write(file);
    for (glue in builtGlues) {
      ret.writeByte(':'.code);
      ret.writeString(glue.path);
      ret.writeByte('\n'.code);
      if (glue.isScript) {
        ret.writeString('=script\n');
      }
      for (glue in glue.glues) {
        ret.writeByte('+'.code);
        ret.writeString(glue);
        ret.writeByte('\n'.code);
      }
    }
    ret.close();
  }

  private static function writeFileDeps(fileDeps:Map<String, Bool>, target:String) {
    var ret = sys.io.File.write(target);
    for (dep in fileDeps.keys()) {
      if (dep.startsWith(externsDir)) {
        if (fileDeps[dep]) {
          ret.writeByte('E'.code);
          dep = dep.substr(externsDir.length);
        }
      } else if (fileDeps[dep]) {
        ret.writeByte('C'.code);
      } else {
        ret.writeByte('I'.code);
      }
      ret.writeString(dep);
      ret.writeByte('\n'.code);
    }
    ret.close();
  }

  private static function getModules(path:String, modules:Array<String>, ?paths:Array<String>)
  {
    function recurse(path:String, pack:String)
    {
      for (file in Globals.cur.fs.readDirectory(path))
      {
        if (file.endsWith('.hx')) {
          modules.push(pack + file.substr(0,-3));
          if (paths != null) {
            paths.push('$path/$file');
          }
        } else if (Globals.cur.fs.isDirectory('$path/$file')) {
          recurse('$path/$file', pack + file + '.');
        }
      }
    }

    if (Globals.cur.fs.exists(path)) recurse(path, '');
  }

  /**
    Registers onGenerate handler once per compilation
   **/
  private static function registerMacroCalls() {
    if (hasRun) return;
    hasRun = true;
    if (firstCompilation) {
      firstCompilation = false;
      #if !haxe4
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
      #end

      if (Context.defined('WITH_CPPIA')) {
        var clsDef = macro class StaticMetaData {};
        clsDef.pack = ['uhx','meta'];
        clsDef.meta = [{ name:':keep', pos:clsDef.pos }];
        Context.defineType(clsDef);
      }
    }
    Globals.cur.setHaxeRuntimeDir();
    haxe.macro.Compiler.include('uhx.expose');
    haxe.macro.Compiler.include('uhx.runtime');
  }

  private static function excludeModules(modules:Array<Array<Type>>) {
    var uobj = Context.getType('unreal.UObject'),
        ustruct = Context.getType('unreal.Struct');
    for (module in modules) {
      for (type in module) {
        var type = type;
        var isTypedef = false;
        while (type != null)
        {
          switch(type) {
          case TInst(c,_):
            if (isTypedef)
            {
              // typedef might point to a static target
              break;
            }
            var c = c.get();
            if (c.meta.has(':ustatic')) {
              break;
            }
            c.meta.remove(':native');
            if (Context.unify(type, uobj)) {
              c.meta.add(':native', [macro $v{'unreal.UObject'}], c.pos);
              c.meta.add(':include', [macro $v{'unreal/UObject.h'}], c.pos);
              c.exclude();
            } else if (c.pack[0] != "haxe" && c.pack[0] != "cpp" && c.pack[0] != "sys") {
              c.meta.add(':native', [macro $v{'Dynamic'}], c.pos);
              c.exclude();
            }
          case TAbstract(a,_):
            // it seems cppia is smart enough to replace abstract types. So we may want to not exclude them
            // it will work either way!
            var a = a.get();
            if (Context.unify(type, ustruct) && a.meta.has(':uscript')) {
              a.impl.get().exclude();
            }
          case TType(_):
            isTypedef = true;
            type = Context.follow(type, true);
            continue;
          case _:
          }
          break;
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
          for (field in cl.fields.get()) {
            Context.follow(field.type);
          }
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

  private static function keepEnums(modules:Array<Array<Type>>) {
    for (module in modules) {
      for (type in module) {
        switch(Context.follow(type)) {
        case TEnum(e,_):
          var e = e.get();
          e.meta.add(':keep', [], e.pos);
          UEnumBuild.processEnum(type);
        case _:
        }
      }
    }
  }
}