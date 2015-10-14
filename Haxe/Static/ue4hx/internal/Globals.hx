package ue4hx.internal;
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

    trace(dir);
#if !bake_externs
    if (dir == null) {
      Context.warning('Unreal Glue: The haxe_runtime_dir directive is not set. This compilation may fail', Context.currentPos());
    }
    else
#end
    {
      haxeRuntimeDir = FileSystem.fullPath(dir);
    }
  }


  public static function reset() {
    cur = new Globals();
  }

  public var builtGlueTypes:Map<String,Bool> = new Map();
  public var buildingGlueTypes:Map<String,DelayedGlue> = new Map();
  public var uobject:Type;
  public var gluesToGenerate:Lst<String>;
  public var uextensions:Lst<String>;

  function new() {
  }
}
