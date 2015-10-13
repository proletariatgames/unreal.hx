package ue4hx.internal;
import haxe.macro.Type;

class Globals {
  public static var current(default,null):Globals = new Globals();

  public static function reset() {
    current = new Globals();
  }

  public var builtGlueTypes:Map<String,Bool> = new Map();
  public var buildingGlueTypes:Map<String,DelayedGlue> = new Map();
  public var uobject:Type;

  public function new() {
  }
}
