package unreal;
import unreal.helpers.HaxeHelpers;

@:forward abstract FName(FNameImpl) from FNameImpl to FNameImpl {
#if !bake_externs
  inline public function new(str:String) {
    this = FNameImpl.create(str);
  }

  inline public static function create(str:String):unreal.PHaxeCreated<FName> {
    return FNameImpl.create(str);
  }

  inline static function createInt(name:UnrealName) : unreal.PHaxeCreated<FName> {
    return FNameImpl.createFromInt(name);
  }

  @:from inline private static function fromName(name:UnrealName) : FName {
    return createInt(name);
  }

  @:from inline private static function fromString(str:String):FName {
    return create(str);
  }

  public function toString():String {
    return this.ToString().toString();
  }

  @:op(A==B) inline public function equals(other:FName) : Bool {
    if (this == null)
      return other == null;
    else
      return CoreAPI.equals(this, other);
  }
#end
}

