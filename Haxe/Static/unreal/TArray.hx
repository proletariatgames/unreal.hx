package unreal;
import unreal.helpers.HaxeHelpers;

#if !bake_externs
using unreal.CoreAPI;
#end

@:forward abstract TArray<T>(TArrayImpl<T>) from TArrayImpl<T> to TArrayImpl<T> {
#if !bake_externs

  public var length(get,never):Int;

  inline public function new(arr:TArrayImpl<T>) {
    this = arr;
  }

  private inline function get_length() {
    return this.Num();
  }

  @:arrayAccess
  public inline function get(index:Int) {
    return this.get_Item(index);
  }

  @:arrayAccess
  public inline function set(index:Int, v:T) : T {
    this.set_Item(index, v);
    return v;
  }

  public function pop(allowShrinking:Bool = true) : T {
    return this.Pop(allowShrinking);
  }


  public function push(obj:T) : Void {
    this.Push(obj);
  }


  public function setNumUninitialized(arraySize:Int) : Void {
    this.SetNumUninitialized(arraySize);
  }

  public function insert(item:T, index:Int) : Int {
    return this.Insert(item, index);
  }

  public function empty() : Void {
    return this.Empty();
  }


  public function find(obj:T) : Int {
    for(i in 0...length) {
      if (get(i).equals(obj)) {
        return i;
      }
    }
    return -1;
  }

#end
}