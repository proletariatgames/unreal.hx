package unreal;
import cpp.Pointer;

@:uobject
class UObject
{
  private var wrapped:UObject_Native;
  private function new(native:Pointer<Void>)
  {
    this.wrapped = cast native;
  }

  public function IsAsset():Bool
  {
    return wrapped.IsAsset();
  }
}

@:include("UObject/UObject.h")
@:native("UObject *")
extern class UObject_Native
{
  // bool uobject_IsAsset(void *self);
  public function IsAsset():Bool;
}
