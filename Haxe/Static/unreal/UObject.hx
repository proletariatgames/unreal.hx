package unreal;

class UObject
{
  private var wrapped:UObject_Native;
  private function new(native:UObject_Native)
  {
    this.wrapped = native;
  }

  public function IsAsset():Bool
  {
    return wrapped.IsAsset();
  }
}

@:include("UObject/UObject.h")
@:native("UObject")
extern class UObject_Native
{
  public function IsAsset():Bool;
}
