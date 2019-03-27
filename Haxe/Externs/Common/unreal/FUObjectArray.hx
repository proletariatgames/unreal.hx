package unreal;

@:glueCppIncludes("UObject/UObjectArray.h")
@:noCopy @:noEquals
@:uextern extern class FUObjectArray {

  @:glueCppIncludes("UObject/UObjectArray.h")
  @:global public static var GUObjectArray(default,never):FUObjectArray;

  public function ObjectToIndex(obj:UObject):Int32;

  public function ObjectToObjectItem(obj:UObject) : PPtr<FUObjectItem>;

 	/**
  * If there's enough slack in the disregard pool, we can re-open it and keep adding objects to it
  */
  public function OpenDisregardForGC() : Void;
  /** After the initial load, this closes the disregard pool so that new object are GC-able */
  public function CloseDisregardForGC() : Void;

  // public function IndexToObject(index:Int32):UObject;
}
