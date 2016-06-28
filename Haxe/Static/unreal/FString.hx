package unreal;

/**
  Represents an Unreal String - will be converted to a normal Haxe String
 **/
@:forward abstract FString(FStringImpl) from FStringImpl to FStringImpl #if !bake_externs to Struct to VariantPtr #end {
#if !bake_externs
  inline public function new(str:String) {
    this = FStringImpl.create(str);
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

  @:op(A==B) inline public function equals(other:FString) : Bool {
    if (this == null)
      return other == null;
    else
      return this.equals(other);
  }
#end
}
