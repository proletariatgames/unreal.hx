package unreal;

@:glueCppIncludes("UObject/UObjectArray.h")
@:noCopy @:noEquals
@:uextern extern class FUObjectArray {

  @:glueCppIncludes("UObject/UObjectArray.h")
  @:global public static var GUObjectArray(default,never):FUObjectArray;

  public function ObjectToIndex(obj:UObject):Int32;

  // public function IndexToObject(index:Int32):UObject;
}
