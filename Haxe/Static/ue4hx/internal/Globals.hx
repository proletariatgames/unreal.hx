package ue4hx.internal;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import sys.FileSystem;

using StringTools;

/**
  Per-build globals
 **/
class Globals {
  public static var MIN_BUILDTOOL_VERSION_LEVEL = 1;

  public static var cur(default,null):Globals = new Globals();

  @:isVar public var haxeRuntimeDir(get,null):String;
  public var module(get,null):String;

  private function get_haxeRuntimeDir() {
    if (haxeRuntimeDir != null)
      return haxeRuntimeDir;

    setHaxeRuntimeDir();
    return haxeRuntimeDir;
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
      Context.warning('Unreal Glue: The haxe_runtime_dir directive is not set. This compilation may fail', Context.currentPos());
    }
    else
#end
    {
      haxeRuntimeDir = FileSystem.fullPath(dir).replace('\\','/');
    }
  }


  public static function reset() {
    cur = new Globals();
  }

  public var builtGlueTypes:Map<String,Bool> = new Map();
  public var buildingGlueTypes:Map<String,DelayedGlue> = new Map();
  public var uobject:Type;
  /**
    Linked list of glue types that need to be generated
   **/
  public var gluesToGenerate:Lst<String>;
  /**
    Linked list of uobject extensions which need to be exposed
   **/
  public var uextensions:Lst<String>;
  /**
    This determines which type parameter glues need to be built. It gets added whenever
    a TypeConv is created with a type that has type parameters, and is consumed asynchronously
   **/
  public var typeParamsToBuild:Lst<{ base:BaseType, args:Array<TypeConv>, pos:Position }>;
  /**
    In order to avoid infinite cycles of type parameter glue building, this keeps a list of all
    type parameters that were already built
   **/
  public var builtParams:Map<String, Bool> = new Map();

  /**
    Linked list of types that have type parameters
   **/
  public var typesWithTParams:Lst<String>;

  public var gluesTouched:Map<String,Bool> = new Map();
  public var canCreateTypes:Bool;

  function new() {
  }
}
