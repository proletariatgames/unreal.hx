package unreal;
import unreal.helpers.HaxeHelpers;

@:forward abstract FName(FNameImpl) from FNameImpl to FNameImpl #if !bake_externs to Struct to VariantPtr #end  {
#if !bake_externs
  inline public function new(str:String) {
    this = FNameImpl.create(str);
  }

  inline public static function create(str:String):FName {
    return FNameImpl.create(str);
  }

  inline public static function createInt(name:UnrealName):FName {
    return FNameImpl.createFromInt(name);
  }

  @:from inline public static function fromName(name:UnrealName):FName {
    return createInt(name);
  }

  @:from inline public static function fromString(str:String):FName {
    return create(str);
  }

  public function toString():String {
    return this.ToString().toString();
  }

  @:op(A==B) #if !debug inline #end public function equals(other:FName) : Bool {
    return (this == null) ? other == null : this.equals(other);
  }
#end
}

