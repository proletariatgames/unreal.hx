package unreal;

@:glueCppIncludes('Containers/Set.h')
@:uextern extern class FSetElementId {
  function new():Void;

  /** @return a boolean value representing whether the id is NULL. */
  function IsValidId():Bool;

  function AsInteger():Int32;

  static function FromInteger(Integer:Int32):FSetElementId;
}
