package unreal;
import unreal.helpers.FName_Glue;
import unreal.helpers.HaxeHelpers;

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
  public inline function arrayWrite(index:Int, v:T) : T {
    this.set_Item(index, v);
    return v;
  }


  public function Find(obj:T) : Int {
    for(i in 0...length) {
      if (get(i) == obj) {
        return i;
      }
    }
    return -1;
  }

#end
}
