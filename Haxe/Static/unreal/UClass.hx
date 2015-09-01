package unreal;
import unreal.forward.UClass as UClass_Fwd;

@:uobject
@:headerCode('class UClass;')
class UClass extends UObject
{
  private function new(native:cpp.Pointer<UClass_Fwd>)
  {
    super(native.reinterpret());
  }

  public static function StaticClass():UClass
  {
    return new UClass(cpp.Pointer.fromRaw(UClass_Glue.StaticClass()));
  }
}

@:uobjectGlue("UClass", "UObject/Class.h")
private extern class UClass_Glue
{
  public static function StaticClass():cpp.RawPointer<UClass_Fwd>;
}

