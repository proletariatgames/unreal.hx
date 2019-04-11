package uhx.compiletime;
import haxe.CallStack;
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
  public static var MIN_BUILDTOOL_VERSION_LEVEL = 7;

  public static var cur(default,null):Globals = new Globals();

  public var id = Std.random(65535);
  /**
    The target unreal source dir
    e.g. {projectDir}/Source/{project}
   **/
  @:isVar public var unrealSourceDir(get,null):String;

  /**
    The target hxcpp directory
    e.g. {projectDir}/Intermediate/Haxe/{project}-Win64-Development-Editor
   **/
  @:isVar public var staticBaseDir(get,null):String;

  @:isVar public var inCompilationServer(get,null):Bool;
  @:isVar public var pluginDir(default, null):String = Context.definedValue('UHX_PLUGIN_PATH');

  public var module(get,null):String;
  public var glueUnityBuild(default, null):Bool = !Context.defined('no_unity_build');
  public var withEditor(default, null):Bool = Context.defined('WITH_EDITOR');
  public var configuration(default, null):String = Context.definedValue('UHX_UE_CONFIGURATION');
  public var targetType(default, null):String = Context.definedValue('UHX_UE_TARGET_TYPE');
  public var targetPlatform(default, null):String = Context.definedValue('UHX_UE_TARGET_PLATFORM');
  public var buildName(default, null):String = Context.definedValue('UHX_BUILD_NAME');
  public var allCompiledModules(default, null):Map<String, Bool> = new Map();
  public var glueManager:Null<uhx.compiletime.types.GlueManager>;
  public var compiledModules:{ stamp:Float, modules:Map<String, Bool> };
  public var liveReloadModules:Map<String, Bool> = new Map();

  var compiledScriptGlues:Map<String, Bool> = new Map();
  var compiledScriptGluesByName:Map<String, Array<String>> = new Map();
  public var compiledScriptGlueTypes:Array<String> = [];

  @:isVar public var shortBuildName(get, null):String;

  public function readScriptGlues(path:String):Void {
    var scriptGlues = new Map(),
        byName = new Map(),
        curArr = null,
        scriptGlueTypes = [];
    var curBase = null;
    var file = sys.io.File.read(path);
    try {
      while(true) {
        var ln = file.readLine();
        if (ln == '') continue;
        switch (ln.charCodeAt(0)) {
        case ':'.code:
          var cur = ln.substr(1);
          curBase = cur + ':';
          scriptGlues[curBase] = false;
          byName[cur] = curArr = [];
        case '+'.code:
          var cur = ln.substr(1);
          scriptGlues[curBase + cur] = false;
          curArr.push(cur);
        case '='.code:
          if (ln == '=script') {
            scriptGlueTypes.push(curBase.substr(0,curBase.length-1));
          }
        case _:
          throw '$path: Unknown script glue part $ln';
        }
      }
    }
    catch(e:haxe.io.Eof) {
    }

    file.close();
    this.compiledScriptGlues = scriptGlues;
    this.compiledScriptGluesByName = byName;
    this.compiledScriptGlueTypes = scriptGlueTypes;
  }

  public function getCompiled(target:String):{ stamp:Null<Float>, modules:Map<String, Bool> } {
    var ret = new Map(),
        path = '$target/Data/compiled.txt';
    if (!FileSystem.exists(path)) {
      return { stamp:null, modules:ret };
    }
    var stamp = FileSystem.stat(path).mtime.getTime(),
        file = sys.io.File.read(path);
    try {
      while(true) {
        var cur = file.readLine();
        ret[cur] = true;
      }
    }
    catch(e:haxe.io.Eof) {
    }
    file.close();

    for (c in ret.keys()) {
      this.allCompiledModules[c] = true;
    }

    return this.compiledModules = { stamp:stamp, modules:ret };
  }

  public function getScriptGluesByName(name:String) {
    var ret = this.compiledScriptGluesByName[name];
    if (ret != null) {
      compiledScriptGlues[name + ':'] = true;
    }
    return ret;
  }

  public function compiledScriptGluesExists(sig:String):Bool {
    if (compiledScriptGlues.exists(sig)) {
      compiledScriptGlues[sig] = true;
      return true;
    }
    return false;
  }

  public function compiledScriptGlueWasTouched(sig:String):Bool {
    return compiledScriptGlues.get(sig);
  }

  private function get_unrealSourceDir() {
    if (this.unrealSourceDir == null) {
      this.setHaxeRuntimeDir();
    }
    return this.unrealSourceDir;
  }

  private function get_staticBaseDir() {
    if (this.staticBaseDir == null) {
      this.staticBaseDir = haxe.io.Path.normalize(
        (Context.defined('cppia') ? Context.definedValue('UHX_STATIC_BASE_DIR') : (haxe.macro.Compiler.getOutput() + '/..'))
      );
    }
    return this.staticBaseDir;
  }

  private function get_inCompilationServer() {
    if (this.inCompilationServer != null) {
      return this.inCompilationServer;
    }
    var target = staticBaseDir;
    target += '/Data/compserver.txt';
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
    var ret = unrealSourceDir.replace('\\','/');
    while (ret.endsWith('/'))
      ret = ret.substr(0,-1);
    return ret.substr(ret.lastIndexOf('/')+1);
  }

  public function setHaxeRuntimeDir() {
    var dir = unrealSourceDir = Context.definedValue('UHX_UNREAL_SOURCE_DIR');

#if !bake_externs
    if (dir == null) {
      if (!Context.defined('cppia')) {
        Context.warning('Unreal Glue: The UHX_UNREAL_SOURCE_DIR directive is not set. This compilation may fail', Context.currentPos());
      }
    }
    else
#end
    {
      unrealSourceDir = FileSystem.fullPath(dir).replace('\\','/');
    }
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
    The unreal.AActor type cached
   **/
  public var aactor:Type;

  /**
    The unreal.UActorComponent type cached
   **/
  public var uactorcomponent:Type;

  /**
    A cache for the Void TypeConv
   **/
  @:isVar public var voidTypeConv(get,null):TypeConv;

  /**
    All live reload functions that were gathered during the build
   **/
  public var explicitLiveReloadFunctions:Map<String, Array<{ functionName:String }>> = new Map();

  /**
    The hashes of each live reload-enabled class
  **/
  public var liveHashes:Map<String, String> = new Map();

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
    Types that will be created dynamically and thus need to have their metadata created
   **/
  public var delegatesToAddMetaDef:Array<{ uname:String, hxName:String, isMulticast:Bool, args:Array<{ name:String, conv:TypeConv}>, ret:TypeConv, pos:Position }> = [];

  /**
    A list of unreal types created by Haxe that were compiled in the static build phase
   **/
  public var staticUTypes:Map<String, StaticMeta> = new Map();

  /**
    A list of unreal types created by Haxe that were compiled in the script build phase.
    This also contains their metadata definition of uproperties/ufunctions,
   **/
  public var scriptClassesDefs:Map<String, { className:String, meta:uhx.meta.MetaDef }> = new Map();
  public var scriptClasses:Array<String> = [];

  /**
    A list of unreal delegates created by Haxe that were compiled in the script build phase.
   **/
  public var scriptDelegateDefs:Map<String, uhx.meta.MetaDef.UDelegateDef> = new Map();

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
    A list of modules that are compiled in the static pass
    only used when cppia is defined
   **/
  public var staticModules:Map<String, Bool> = new Map();

  public static var registeredMacro:Bool;

  private static var generateHooks:Map<String, Array<Type>->Void>;

  public static function addGenerateHook(name:String, fn:Array<Type>->Void) {
    if (generateHooks == null) {
      generateHooks = new Map();
    }
    generateHooks[name] = fn;
  }

  public static function callGenerateHooks(types:Array<Type>) {
    if (generateHooks != null) {
      for (hook in generateHooks) {
        hook(types);
      }
    }
  }

  function new() {
    TypeConv.addSpecialTypes(this.typeConvCache);
  }

  private function get_voidTypeConv() {
    if (voidTypeConv == null) {
      this.voidTypeConv = TypeConv.get(Context.getType('Void'), Context.currentPos());
    }
    return this.voidTypeConv;
  }

  private function get_shortBuildName() {
    if (this.shortBuildName == null) {
      var bn = buildName.split('-');
      bn.shift();
      switch(bn[1]) {
      case 'Development':
        bn[1] = 'Dev';
      case 'Shipping':
        bn[1] = 'Ship';
      case 'Debug':
        bn[1] = 'Dbg';
      }
      this.shortBuildName = bn.join('-');
    }
    return this.shortBuildName;
  }

  /**
    Checks if the latest compilation was using the same defines as this
   **/
  public function checkOlderCache() {
    if (hasOlderCache == null) {
      var dir = unrealSourceDir;
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
    var dir = unrealSourceDir;
    if (!FileSystem.exists('$dir/Generated')) {
      FileSystem.createDirectory('$dir/Generated');
    }
    File.saveContent('$dir/Generated/defines.txt', '');
  }

  /**
    Sets the cache file to indicate that the last compilation was using our defines
   **/
  public function setCacheFile() {
    if (Context.defined('cppia')) {
      throw 'SetCacheFile must only be called by native builds';
    }

    var dir = unrealSourceDir;
    if (!FileSystem.exists('$dir/Generated')) {
      FileSystem.createDirectory('$dir/Generated');
    }
    var str = getDefinesString();
    File.saveContent('$dir/Generated/defines.txt', str);
  }

  public function addScriptDef(name:String, def:{ className:String, meta:uhx.meta.MetaDef }) {
    if (!scriptClassesDefs.exists(name)) {
      scriptClasses.push(name);
    }
    scriptClassesDefs[name] = def;
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
    return cl.meta.has(':uscript') && !Context.defined('NO_DYNAMIC_UCLASS') && !cl.meta.has(':upropertyExpose') && !cl.meta.has(':ustruct');
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
  public static function shouldExposeFunction(cf:ClassField, isDynamicUType:Bool, originalNativeField:Null<ClassField>) {
    if (!cf.kind.match(FMethod(_))) {
      return false;
    }

    if (originalNativeField != null) { // is override
      var ufunc = originalNativeField.meta.extract(":ufunction");
      if (ufunc != null) {
        for (meta in ufunc) {
          for (meta in meta.params) {
            if (UExtensionBuild.ufuncBlueprintOverridable(meta)) {
              if (isDynamicUType) {
                return false;
              } else {
                return true;
              }
            }
          }
        }
      }
      return true;
    }

    return cf.meta.has(':uexpose') || (!isDynamicUType && cf.meta.has(':ufunction'));
  }

  public static function shouldExposeFunctionExpr(cf:Field, isDynamicUType:Bool, originalNativeField:Null<ClassField>) {
    if (!cf.kind.match(FFun(_))) {
      return false;
    }

    if (originalNativeField != null) {
      var ufunc = originalNativeField.meta.extract(":ufunction");
      if (ufunc != null) {
        for (meta in ufunc) {
          for (meta in meta.params) {
            if (UExtensionBuild.ufuncBlueprintOverridable(meta)) {
              if (isDynamicUType) {
                return false;
              } else {
                return true;
              }
            }
          }
        }
      }
      return true;
    }

    return cf.meta.hasMeta(':uexpose') || (!isDynamicUType && cf.meta.hasMeta(':ufunction'));
  }

  public static inline var UHX_CALL_FUNCTION = 'uhx_callFunction';
}
