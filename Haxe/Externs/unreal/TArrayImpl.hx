package unreal;

/**
  The main Unreal Object class
 **/
@:glueCppIncludes("Containers/Array.h")
@:uname("TArray")
@:noEquals
@:uextern extern class TArrayImpl<T>
{
  public function get_Item(index:Int):PRef<T>;
  @:uIfAssign("T","T") public function set_Item(index:Int, val:PRef<T>):Void;
  public function Pop(allowShrinking:Bool):T;
  public function Push(obj:PRef<PRef<T>>):Void;
  public function AddZeroed(Count:Int32) : Int32;
  public function SetNumUninitialized(arraySize:Int):Void;
  public function Insert(item:PRef<PRef<T>>, index:Int):Int;
  public function RemoveAt(Index:Int32, Count:Int32, bAllowShrinking:Bool):Void;
  public function Num():Int;
  public function Empty():Void;

  @:uname('new') static function create<T>():PHaxeCreated<TArray<T>>;
}
