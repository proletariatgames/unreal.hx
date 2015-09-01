package unreal;
import unreal.forward.UObject as UObject_Fwd;

@:uobject
@:headerCode('class UObject;')
class UObject
{
  private var wrapped:cpp.RawPointer<cpp.Void>;
  private function new(native:cpp.Pointer<UObject_Fwd>)
  {
    this.wrapped = native.rawCast();
  }

  public function IsAsset():Bool
  {
    return UObject_Glue.IsAsset(cast wrapped);
  }
}

@:uobjectGlue("UObject", "UObject/UObject.h")
private extern class UObject_Glue
{
  @:member public static function IsAsset(obj:cpp.RawPointer<UObject_Fwd>):Bool;
}
