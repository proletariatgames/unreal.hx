package ue4hx.internal;
import ue4hx.internal.TypeConv;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

using StringTools;

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

  public var modulesToProcess:Lst<{ module:String, pack:Array<String> }>;

  public var gluesTouched:Map<String,Bool> = new Map();
  public var hasOlderCache:Null<Bool>;
  public var inScriptPass:Bool = false;
  // only used when cppia is defined
  public var scriptModules:Map<String, Bool> = new Map();

  private var modulesSeen:Map<String, Array<String>> = new Map();

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

  public function markModule(module:String, pack:Array<String>) {
    if (!modulesSeen.exists(module)) {
      this.modulesToProcess = this.modulesToProcess.add({ module:module, pack:pack });
      this.modulesSeen[module] = pack;
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
      trace('loading cache...');
      // first we'll create the type if it doesn't exist
      try {
        Context.getType('ue4hx.CachedData');
      } catch(e:Dynamic) {
        Context.defineType({
          name:'CachedData',
          pack:['ue4hx'],
          pos: Context.currentPos(),
          kind: TDClass(),
          fields: []
        });
      }

      switch(Context.getType('ue4hx.CachedData')) {
        case TInst(_.get() => c,_):
          if (c.meta.has(':savedTypes')) {
            for (type in MacroHelpers.extractStrings(c.meta, ':savedTypes')) {
              try {
                Context.getType(type);
                this.cachedBuiltTypes.push(type);
              }
              catch(e:Dynamic) {
                trace('Type $type not found. Perhaps it was deleted?');
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
      trace('saving cached types...');
      if (this.cachedBuiltTypes.length > 0) {
        switch(Context.getType('ue4hx.CachedData')) {
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
}
