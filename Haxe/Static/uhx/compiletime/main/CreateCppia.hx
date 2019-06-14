package uhx.compiletime.main;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import uhx.compiletime.types.TypeRef;

using uhx.compiletime.tools.MacroHelpers;
using StringTools;
using Lambda;

class CreateCppia {
  static var firstCompilation = true;
  static var hasRun = false;
  static var externsDir:String;

  public static function run(staticPaths:Array<String>, scriptPaths:Array<String>, ?excludeModules:Array<String>) {
    Globals.cur.checkBuildVersionLevel();
    externsDir = Context.definedValue('UHX_BAKE_DIR');
    var target = Globals.cur.staticBaseDir;
    var compiled = Globals.cur.getCompiled(target).modules;

    registerMacroCalls(target);
    Globals.cur.readScriptGlues('$target/Data/scriptGlues.txt');

    var statics = [];
    for (path in staticPaths) {
      getModules(path,statics);
    }

    Globals.cur.inScriptPass = true;
    var scripts = [],
        scriptFullPaths = [];
    for (path in scriptPaths) {
      getModules(path,scripts,scriptFullPaths);
    }
    Globals.cur.staticModules = [ for (module in statics) module => true ];
    var modules = [ for (module in scripts) Context.getModule(module) ];
    if (target != null && Globals.cur.fs.exists('$target/Data/livereload.txt')) {
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
    // var scriptFiles = ensureCompiled(modules);
    // Globals.cur.inScriptPass = false;

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
      'unreal.Int64Helpers'
    ];

    addTimestamp();

    try {
      Context.getType('uhx.meta.CppiaMetaData');
    }
    catch(e:Dynamic) {
      var clsDef = macro class CppiaMetaData {};
      clsDef.pack = ['uhx','meta'];
      clsDef.meta = [{ name:':keep', pos:clsDef.pos }];
      Context.defineType(clsDef);
      Context.getType('uhx.meta.CppiaMetaData');
    }

    try{
      Context.getType('uhx.meta.MetaDataHelper');
    }
    catch(e:Dynamic) {
      var clsDef = macro class MetaDataHelper {};
      clsDef.pack = ['uhx','meta'];
      clsDef.meta = [{ name:':keep', pos:clsDef.pos }];
      Context.defineType(clsDef);
      Context.getType('uhx.meta.MetaDataHelper');
    }

    var finalized = false;
    Context.onAfterTyping(function(types) {
      if (types.exists(function(t) return Std.string(t) == 'TClassDecl(uhx.compiletime.main.CreateCppia)')) {
        return; // macro context
      }
      Globals.cur.hasUnprocessedTypes = false;

      if (!finalized && !Globals.cur.hasUnprocessedTypes) {
        finalized = true;
        var metaDefs = Globals.cur.classesToAddMetaDef;
        var cur = null;
        while ( (cur = metaDefs.pop()) != null ) {
          var type = Context.getType(cur);
          switch(type) {
          case TInst(c,_):
            MetaDefBuild.addUClassMetaDef(c.get());
          case _:
          }
        }

        var metaDefs = Globals.cur.delegatesToAddMetaDef;
        var cur = null;
        while ( (cur = metaDefs.pop()) != null ) {
          MetaDefBuild.addUDelegateMetaDef(cur);
        }

        var liveFuncs = Globals.cur.explicitLiveReloadFunctions;
        if (liveFuncs.iterator().hasNext())
        {
          uhx.compiletime.LiveReloadBuild.createBindFunctionsMain('uhx.LiveReloadScript');
        }

        MetaDefBuild.writeClassDefs();

        Globals.cur.classesToAddMetaDef = [];
        Globals.cur.delegatesToAddMetaDef = [];
      }
    });

    var fileDeps = new Map();
    for (path in scriptFullPaths) {
      fileDeps[path] = true;
    }
    inline function addFileDep(file:String) {
      if (file != null && file.endsWith('.hx')) {
        fileDeps.set(file, true);
      }
    }
    Context.onGenerate(function(types) {
      Globals.callGenerateHooks(types);
      LiveReloadBuild.onGenerate(types);
      var metaDefs = Globals.cur.classesToAddMetaDef;
      if (metaDefs.length != 0) {
        throw 'assert: sanity check failed. there are still classesToAddMetaDef';
      }

      var metaDefs = Globals.cur.delegatesToAddMetaDef;
      if (metaDefs.length != 0) {
        throw 'assert: sanity check failed. there are still classesToAddMetaDef';
      }

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

      var regModules = new Map(),
          compiledPath = '$target/Data/compiled.txt',
          allTypes = new Map();
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
          return module.startsWith('cpp.') || module.startsWith('sys.');
        }
      }
      for (type in types) {
        var typeToCheck = null,
            curPos = null;
        switch(type) {
          case TInst(c,_):
            var name = c.toString();
            allTypes[name] = type;
            var c = c.get();
            curPos = c.pos;
            var isExtern = c.meta.has(':uextern');
            if (c.meta.has(':uscript') && c.meta.has(':uclass')) {
              typeToCheck = name;
              if (c.superClass != null) {
                var superClass = c.superClass.t.get().getUName();
                if (!Globals.cur.compiledScriptGluesExists(name + ':' + superClass)) {
                  Context.warning('UHXERR: The type $name was compiled with a different superclass since the last C++ compilation. A full C++ compilation is required', Context.currentPos());
                }
              }
            }
            addFileDep(Context.getPosInfos(c.pos).file);
            if (isExtern) {
              var name = TypeRef.fastClassPath(c);
              if (c.isInterface || compiled.exists(name)) {
                c.exclude();
                var mod = c.module;
                if (!regModules.exists(mod)) {
                  regModules[mod] = true;
                  Context.registerModuleDependency(mod, compiledPath);
                }
              }
            } else if (hasExclude(c.module) || c.meta.has(':coreApi')) {
              if (c.name != 'UnrealCppia') {
                c.exclude();
              }
            } else {
              switch(c.pack) {
              case ['uhx','internal'] | ['uhx','expose']:
                c.exclude();
              case _:
              }
            }

          case TEnum(eRef,_):
            allTypes[eRef.toString()] = type;
            var e = eRef.get();
            curPos = e.pos;
            addFileDep(Context.getPosInfos(e.pos).file);
            if (!e.meta.has(':uextern')) {
              var sig = UEnumBuild.getSignature(e);
              if (sig != null) {
                if (!Globals.cur.compiledScriptGluesExists(eRef.toString() + ':' + sig) && !Context.defined('UHX_DISPLAY')) {
                  Context.warning('UHXERR: The enum $eRef was not compiled into static, or it was compiled with a different signature. A full C++ compilation is required', e.pos);
                }
              }
            }
            if (hasExclude(e.module)) {
              e.exclude();
            }
          case TAbstract(at,_):
            allTypes[at.toString()] = type;
            var a = at.get();
            curPos = a.pos;
            var isExtern = a.meta.has(':uextern');
            addFileDep(Context.getPosInfos(a.pos).file);
            if (a.meta.has(':uscript')) {
              if (!a.meta.has(':udelegate')) {
                typeToCheck = a.impl != null ? a.impl.toString() : at.toString();
              }
            } else if (isExtern) {
              var name = TypeRef.fastClassPath(a);
              if (compiled.exists(name)) {
                var impl = a.impl;
                if (impl != null) {
                  impl.get().exclude();
                }
                var mod = a.module;
                if (!regModules.exists(mod)) {
                  regModules[mod] = true;
                  Context.registerModuleDependency(mod, compiledPath);
                }
              }
            } else if (hasExclude(a.module) || a.meta.has(':coreApi')) {
              var impl = a.impl;
              if (impl != null) {
                impl.get().exclude();
              }
            }
          case TType(tt,_):
            allTypes[tt.toString()] = type;
            var t = tt.get();
            curPos = t.pos;
            if (!Globals.cur.staticModules.exists(t.module)) {
              addFileDep(Context.getPosInfos(t.pos).file);
            }
          case _:
        }

        if (typeToCheck != null) {
          // if the main type was not touched, it means it was previously compiled and the compilation server didn't detect any changes
          if (Globals.cur.compiledScriptGlueWasTouched(typeToCheck + ':')) {
            var scripts = Globals.cur.getScriptGluesByName(typeToCheck);
            if (scripts != null) {
              for (script in scripts) {
                if (script.startsWith('StaticClass()') || script.startsWith('CPPSize()') || script.startsWith('setupFunction(')) {
                  continue;
                }
                if (!Globals.cur.compiledScriptGlueWasTouched(typeToCheck + ':' + script)) {
                  Context.warning('UHXERR: $typeToCheck: The script function $script was changed or deleted since the last C++ compilation. A full C++ compilation is recommended', curPos);
                }
              }
            } else {
              Context.warning('UHXERR: The type $typeToCheck was not compiled since the last C++ compilation. A full C++ compilation is recommended', curPos);
            }
          }
        }
      }

      for (glueType in Globals.cur.compiledScriptGlueTypes) {
        if (!Globals.cur.compiledScriptGlueWasTouched(glueType + ':')) {
          var nameToCheck = glueType;
          if (glueType.endsWith('_Impl_')) {
            var partialNameIdx = glueType.lastIndexOf('.'),
                name = glueType.substring(partialNameIdx + 1, glueType.length - '_Impl_'.length);
            var typeName = new EReg('_$name\\.${name}_Impl_', '');
            if (typeName.match(glueType)) {
              nameToCheck = typeName.matchedLeft() + name;
            }
          }
          if (!allTypes.exists(nameToCheck)) {
            Context.warning('UHXERR: The type $glueType was previously compiled in C++ but it was removed. A full C++ compilation is recommended', Context.currentPos());
          }
        }
      }
    });
    Context.onAfterGenerate( function() {
      writeFileDeps(fileDeps, '$target/Data/cppiaDeps.txt');
      Globals.cur.fs.saveContent('$target/Data/cppiaModules.txt', scripts.join('\n'));
      uhx.compiletime.LiveReloadBuild.saveLiveHashes('cppia-live-hashes.txt');
    });
  }

  private static function writeFileDeps(fileDeps:Map<String, Bool>, target:String) {
    var ret = sys.io.File.write(target);
    for (dep in fileDeps.keys()) {
      if (dep.startsWith(externsDir)) {
        ret.writeByte('E'.code);
        dep = dep.substr(externsDir.length);
      } else {
        ret.writeByte('C'.code);
      }
      ret.writeString(dep);
      ret.writeByte('\n'.code);
    }
    ret.close();
  }

  private static function addTimestamp() {
    // adds a class that returns the timestamp of when it was built.
    // this works around HaxeFoundation/hxcpp#358 by adding logic that determines
    // whether the newly loaded script has the same timestamp as the older one
    var stamp = Date.now().getTime();
    var cls = macro class CppiaCompilation {
      @:keep public static var timestamp(default,null):Float = $v{stamp};
    };
    cls.pack = ['uhx','meta'];
    Globals.cur.hasUnprocessedTypes = true;
    Context.defineType(cls);
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

  private static function ensureCompiled(modules:Array<Array<Type>>) {
    var ret = new Map();
    var ustruct = Context.getType('unreal.Struct');
    for (module in modules) {
      for (type in module) {
        switch(Context.follow(type)) {
        case TInst(c,_):
          var cl = c.get();
          ret.set(Context.getPosInfos(cl.pos).file, true);
          for (field in cl.fields.get())
            Context.follow(field.type);
          for (field in cl.statics.get())
            Context.follow(field.type);
          var ctor = cl.constructor;
          if (ctor != null)
            Context.follow(ctor.get().type);
        case TAbstract(a,_):
          var a = a.get();
          ret.set(Context.getPosInfos(a.pos).file, true);
          if (Context.unify(type, ustruct) && !a.meta.has(':uscript')) {
            a.impl.get().exclude();
            continue;
          }
        case TEnum(e,_):
          var e = e.get();
          ret.set(Context.getPosInfos(e.pos).file, true);
        case _:
        }
      }
    }
    return ret;
  }

  private static function registerMacroCalls(target:String) {
    if (hasRun) return;
    hasRun = true;
    #if !haxe4
    if (firstCompilation) {
      firstCompilation = false;
      Context.onMacroContextReused(function() {
        hasRun = false;

        trace('macro context reused');
        Globals.reset();
        return true;
      });
    }
    #end
    Globals.cur.setHaxeRuntimeDir();
  }
}
