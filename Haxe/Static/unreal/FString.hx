package unreal;

/**
  Represents an Unreal String - will be converted to a normal Haxe String
 **/
@:forward abstract FString(FStringImpl) from FStringImpl to FStringImpl {
#if !bake_externs
  inline public function new(str:String) {
    this = FStringImpl.create(str);
  }

  inline public static function create(str:String):unreal.PHaxeCreated<FString> {
    return FStringImpl.create(str);
  }

  @:from inline private static function fromString(str:String):FString {
    return create(str);
  }

  public function toString():String {
    return this.op_Dereference();
  }
#end
}
