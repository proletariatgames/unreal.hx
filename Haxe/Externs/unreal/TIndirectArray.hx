package unreal;

/**
  The main Unreal Object class
 **/
@:glueCppIncludes("Containers/IndirectArray.h")
@:noEquals
@:uextern extern class TIndirectArray<T>
{
  public function get_Item(index:Int):PRef<T>;
  @:uIfAssign("T","T") public function set_Item(index:Int, val:PRef<T>):Void;
  public function Insert(item:PPtr<T>, index:Int):Void;
  public function RemoveAt(Index:Int32, Count:Int32, bAllowShrinking:Bool):Void;
  public function Num():Int;
  public function Empty():Void;
  public function Reset():Void;
  public function Swap(first:Int, second:Int):Void;

  public function GetData():ConstAnyPtr;

  @:uname('.ctor') static function create<T>():TIndirectArray<T>;
  @:uname('new') static function createNew<T>():POwnedPtr<TIndirectArray<T>>;
}

