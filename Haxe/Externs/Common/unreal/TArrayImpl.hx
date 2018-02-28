package unreal;

/**
  The main Unreal Object class
 **/
@:glueCppIncludes("Containers/Array.h")
@:uname("TArray")
@:noEquals
@:ustruct
@:uextern extern class TArrayImpl<T>
{
  public function get_Item(index:Int):PRef<T>;
  @:uIfAssign("T","T") public function set_Item(index:Int, val:PRef<T>):Void;
  public function Pop(allowShrinking:Bool):T;
  public function Push(obj:PRef<T>):Void;
  public function AddZeroed(Count:Int32) : Int32;
  public function SetNumUninitialized(arraySize:Int):Void;
  public function Insert(item:PRef<T>, index:Int):Int;
  public function RemoveAt(Index:Int32, Count:Int32=1, bAllowShrinking:Bool=true):Void;
  public function Num():Int;
  public function Empty(?NewSize:Int = 0):Void;
  public function Reset(?NewSize:Int = 0):Void;
  public function Swap(first:Int, second:Int):Void;

  public function GetData():ConstAnyPtr;

  @:uname('.ctor') static function create<T>():TArray<T>;
  @:uname('new') static function createNew<T>():POwnedPtr<TArray<T>>;
  @:uname('.ctor') static function copyCreate<T>(Other:Const<PRef<TArray<T>>>):TArray<T>;
  @:uname('new') static function copyCreateNew<T>(Other:Const<PRef<TArray<T>>>):POwnedPtr<TArray<T>>;
}
