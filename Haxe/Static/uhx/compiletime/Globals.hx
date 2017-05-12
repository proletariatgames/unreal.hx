package uhx.compiletime;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;
import uhx.meta.MetaDef;
import uhx.compiletime.types.TypeConv;
import uhx.compiletime.tools.Lst;

using StringTools;
using uhx.compiletime.tools.MacroHelpers;

/**
  Per-build globals
 **/
class Globals {
  public static var MIN_BUILDTOOL_VERSION_LEVEL = 4;

  public static var cur(default,null):Globals = new Globals();

  @:isVar public var haxeRuntimeDir(get,null):String;
  @:isVar public var glueTargetModule(get,null):String;
  @:isVar public var inCompilationServer(get,null):Bool;
  public var module(get,null):String;

  private var targetModuleSet:Bool = false;

  private function get_haxeRuntimeDir() {
    if (this.haxeRuntimeDir == null)
      this.setHaxeRuntimeDir();
    return this.haxeRuntimeDir;
  }
  inline private function get_glueTargetModule() {
    if (this.targetModuleSet) {
      return glueTargetModule;
    } else {
      setGlueTargetModule();
      return glueTargetModule;
    }
  }

  private function get_inCompilationServer() {
    if (this.inCompilationServer != null) {
      return this.inCompilationServer;
    }
    var target = haxe.macro.Compiler.getOutput() + '/Data/compserver.txt';
    if (FileSystem.exists(target)) {
      var ret = File.getContent(target);
      if (ret == "0") {
        return this.inCompilationServer = false;
      } else if (ret == "1") {
        return this.inCompilationServer = true;
      } else {
        trace('Warning: Cannot determine if we are using the compilation server');
        return this.inCompilationServer = false;
      }
    }
    trace('Warning: Compilation server data file missing. Old build tool?');
    return this.inCompilationServer = false;
  }

  private function get_module() {
    var ret = haxeRuntimeDir.replace('\\','/');
    while (ret.endsWith('/'))
      ret = ret.substr(0,-1);
    return ret.substr(ret.lastIndexOf('/')+1);
  }

  public function setHaxeRuntimeDir() {
    var dir = haxeRuntimeDir = Context.definedValue('haxe_runtime_dir');

#if !bake_externs
    if (dir == null) {
      if (!Context.defined('cppia')) {
        Context.warning('Unreal Glue: The haxe_runtime_dir directive is not set. This compilation may fail', Context.currentPos());
      }
    }
    else
#end
    {
      haxeRuntimeDir = FileSystem.fullPath(dir).replace('\\','/');
    }
  }

  public function setGlueTargetModule() {
    this.glueTargetModule = Context.definedValue('glue_target_module');
    this.targetModuleSet = true;
  }


  public static function reset() {
    cur = new Globals();
  }

  public var builtGlueTypes:Map<String,Bool> = new Map();

  /**
    The unreal.UObject type cached
   **/
  public var uobject:Type;

  /**
    All live reload functions that were gathered during the build
    This is static so they can survive through compilations
   **/
  public static var liveReloadFuncs:Map<String, Map<String, TypedExpr>> = new Map();

  /**
    A cache of TypeConv objects
   **/
  public var typeConvCache:Map<String, TypeConv> = new Map();

  /**
    This cache is needed to ensure we all have the same classfield when adding metadata to them,
    otherwise some meta might be lost
   **/
  public var cachedFields:Map<String, Map<String, ClassField>> = new Map();

  /**
    Linked list of glue types that need to be generated
   **/
  public var gluesToGenerate:Lst<String>;

  /**
    Linked list of uobject extensions which need to be exposed
   **/
  public var uextensions:Lst<String>;

  /**
    All script glues to generate
   **/
  public var scriptGlues:Lst<String>;

  /**
    List of all defined types that can be cached in this build. They will be cached so the compilation server can pick it up again
   **/
  public var cachedBuiltTypes:Array<String> = [];

  /**
    List of all delays that are to be executed
   **/
  public var delays:Lst<Void->Void>;

  /**
    Tells whether there are types added to the context
   **/
  public var hasUnprocessedTypes:Bool = false;

  /**
    Types that will be created dynamically and thus need to have their metadata created
   **/
  public var classesToAddMetaDef:Array<String> = [];

  /**
    A list of unreal types created by Haxe that were compiled in the static build phase
   **/
  public var staticUTypes:Map<String, StaticMeta> = new Map();

  /**
    A list of unreal types created by Haxe that were compiled in the script build phase.
    This also contains their metadata definition of uproperties/ufunctions,
   **/
  public var scriptClassDefs:Map<String, { className:String, meta:uhx.meta.MetaDef }> = new Map();

  /**
    Allows to speed up builds by keeping track of the glues that need to be regenerated
   **/
  public var gluesTouched:Map<String,Bool> = new Map();

  /**
    True if the latest compilation was using the same defines as this current.
    Allows to speed up the builds by skipping some files if they have not changed
   **/
  public var hasOlderCache:Null<Bool>;

  /**
    True if we're building the scripts currently
   **/
  public var inScriptPass:Bool = false;

  /**
    A list of modules that are compiled in the script pass
    only used when cppia is defined
   **/
  public var scriptModules:Map<String, Bool> = new Map();

  function new() {
    TypeConv.addSpecialTypes(this.typeConvCache);
  }

  /**
    Checks if the latest compilation was using the same defines as this
   **/
  public function checkOlderCache() {
    if (hasOlderCache == null) {
      var dir = haxeRuntimeDir;
      if (dir == null) return;
      if (FileSystem.exists('$dir/Generated/defines.txt')) {
        var defines = getDefinesString();
        this.hasOlderCache = File.getContent('$dir/Generated/defines.txt') == defines;
      } else {
        this.hasOlderCache = false;
      }
    }
  }

  /**
    Reserves the cache file to mark we're in a inconsistent state. An error between `reserveCacheFile` and
    `setCacheFile` will force the next compilation to flush its cache
   **/
  public function reserveCacheFile() {
    var dir = haxeRuntimeDir;
    if (!FileSystem.exists('$dir/Generated')) {
      FileSystem.createDirectory('$dir/Generated');
    }
    File.saveContent('$dir/Generated/defines.txt', '');
  }

  /**
    Sets the cache file to indicate that the last compilation was using our defines
   **/
  public function setCacheFile() {
    var dir = haxeRuntimeDir;
    if (!FileSystem.exists('$dir/Generated')) {
      FileSystem.createDirectory('$dir/Generated');
    }
    File.saveContent('$dir/Generated/defines.txt', getDefinesString());
  }

  /**
    Loads previously saved type parameters
   **/
  public function loadCachedTypes() {
    if (this.inCompilationServer) {
      // trace('loading cache...');
      // first we'll create the type if it doesn't exist
      try {
        Context.getType('uhx.CachedData');
      } catch(e:Dynamic) {
        Context.defineType({
          name:'CachedData',
          pack:['uhx'],
          pos: Context.currentPos(),
          kind: TDClass(),
          fields: []
        });
      }

      switch(Context.getType('uhx.CachedData')) {
        case TInst(_.get() => c,_):
          if (c.meta.has(':savedTypes')) {
            for (type in c.meta.extractStrings(':savedTypes')) {
              try {
                Context.getType(type);
                this.cachedBuiltTypes.push(type);
              }
              catch(e:Dynamic) {
                // trace('Type $type not found. Perhaps it was deleted?');
              }
            }
          }
        case _:
          throw 'assert';
      }
    }
  }

  /**
    Saves cached types for further compilations
   **/
  public function saveCachedBuilt() {
    if (this.inCompilationServer) {
      // trace('saving cached types...');
      if (this.cachedBuiltTypes.length > 0) {
        switch(Context.getType('uhx.CachedData')) {
          case TInst(_.get() => c,_):
            c.meta.remove(':savedTypes');
            c.meta.add(':savedTypes', [for (t in this.cachedBuiltTypes) macro $v{t}], c.pos);
          case _:
            throw 'assert';
        }
      }
    }
  }

  private function getDefinesString():String {
    var ret = new StringBuf();
    var defs = Context.getDefines();
    var sorted = [ for (def in defs.keys()) def ];
    sorted.sort(Reflect.compare);
    for (def in sorted) {
      if (def == "IN_COMPILATION_SERVER") continue;
      ret.add(def);
      ret.add(' : ');
      ret.add(defs[def]);
      ret.add('\n');
    };
    return ret.toString();
  }

  public function checkBuildVersionLevel() {
    // we need this since we might make some breaking changes on the build system
    // that may need a manual recompilation of BuildTool
    // this function will check if we are running in a compatible build version level
    // and error if we don't
    var buildVer = Context.definedValue('BUILDTOOL_VERSION_LEVEL');
    if (buildVer == null || Std.parseInt(buildVer) < MIN_BUILDTOOL_VERSION_LEVEL) {
      var pos = Context.makePosition({ file: 'UE4Haxe Toolchain', min:0, max:0 });
      Context.fatalError('You have an incompatible build tool build. Please rebuild it by running `haxe init-plugin.hxml` on the plugin directory', pos);
    }
  }


  // helpers
  /**
    True if the `type` is dynamic, and whose properties will be added by cppia at runtime
   **/
  public static function isDynamicUType(cl:BaseType) {
    return cl.meta.has(':uscript') && !Context.defined('NO_DYNAMIC_UCLASS') && !cl.meta.has(':upropExpose') && !cl.meta.has(':ustruct');
  }

  // if you change this, don't forget to change `shouldExposePropertyExpr` as well
  public static function shouldExposeProperty(cf:ClassField, isDynamicUType:Bool) {
    if (cf.kind.match(FMethod(_))) {
      return false;
    }
    return cf.meta.has(':uexpose') || (!isDynamicUType && cf.meta.has(':uproperty'));
  }

  public static function shouldExposePropertyExpr(cf:Field, isDynamicUType:Bool) {
    if (cf.kind.match(FFun(_))) {
      return false;
    }
    return cf.meta.hasMeta(':uexpose') || (!isDynamicUType && cf.meta.hasMeta(':uproperty'));
  }

  // if you change this, don't forget to change `shouldExposeFunctionExpr` as well
  public static function shouldExposeFunction(cf:ClassField, isDynamicUType:Bool, overridesNative:Bool) {
    if (!cf.kind.match(FMethod(_))) {
      return false;
    }

    return overridesNative || cf.meta.has(':uexpose') || (!isDynamicUType && cf.meta.has(':ufunction'));
  }

  public static function shouldExposeFunctionExpr(cf:Field, isDynamicUType:Bool, overridesNative:Bool) {
    if (!cf.kind.match(FFun(_))) {
      return false;
    }

    return overridesNative || cf.meta.hasMeta(':uexpose') || (!isDynamicUType && cf.meta.hasMeta(':ufunction'));
  }

  public static inline var UHX_CALL_FUNCTION = 'uhx_callFunction';
}
