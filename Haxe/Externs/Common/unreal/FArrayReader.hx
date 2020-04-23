package unreal;

@:glueCppIncludes("Serialization/ArrayReader.h")
@:uextern extern class FArrayReader
{
  public function get_Item(index:Int):PRef<UInt8>;
  public function set_Item(index:Int, val:UInt8):Void;
  public function Push(obj:UInt8):Void;
  public function AddZeroed(Count:Int32) : Int32;
  public function Insert(item:PRef<UInt8>, index:Int):Int;
  public function RemoveAt(Index:Int32, Count:Int32=1, bAllowShrinking:Bool=true):Void;
  public function Num():Int;
  public function Empty(?NewSize:Int = 0):Void;
  public function Reset(?NewSize:Int = 0):Void;

  public function GetData():ConstAnyPtr;

  public function Serialize(Data:AnyPtr, Count:Int64):Void;
}