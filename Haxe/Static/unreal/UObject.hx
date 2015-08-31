package unreal;

@:uobject
@:headerCode('class UObject;')
class UObject
{
  private var wrapped:cpp.RawPointer<UObject_Type>;
  private function new(native:cpp.Pointer<UObject_Type>)
  {
    this.wrapped = native.get_raw();
  }

  public function IsAsset():Bool
  {
    return UObject_Glue.IsAsset(wrapped);
  }
}

@:uobjectGlue("UObject", "UObject/UObject.h")
private extern class UObject_Glue
{
  @:member public static function IsAsset(obj:cpp.RawPointer<UObject_Type>):Bool;
}

@:native('UObject')
@:uobjectType
private extern class UObject_Type
{
}
