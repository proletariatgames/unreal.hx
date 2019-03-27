package unreal;

/**
  Represents an Unreal String - will be converted to a normal Haxe String
 **/
@:forward abstract FString(FStringImpl) from FStringImpl to FStringImpl #if !bake_externs to Struct to VariantPtr #end {
#if !bake_externs
  inline public function new(str:String) {
    this = FStringImpl.create(str);
  }

  public var length(get,never):Int;

  inline private function get_length() {
    return this.Len();
  }

  inline public static function create(str:String):FString {
    return FStringImpl.create(str);
  }

  @:from inline public static function fromString(str:String):FString {
    return create(str);
  }

  public function toString():String {
    return this.op_Dereference();
  }

  public function empty(?slack:Int32):Void {
    this.Empty(slack);
  }

  inline public function assign(str:FString):Void {
    this.assign(str);
  }

  @:op(A==B) inline public function equals(other:FString) : Bool {
    if (this == null)
      return other == null;
    else
      return this.equals(other);
  }

  @:op(A!=B) inline public function notEquals(other:FString) : Bool {
    if (this == null)
      return other != null;
    else
      return !this.equals(other);
  }
#end
}
