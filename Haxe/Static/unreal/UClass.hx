package unreal;

@:glueCppIncludes("UObject/Class.h")
@:uobject
class UClass extends UObject
{
  public static function StaticClass():UClass;
}

class UClass_Wrap {
  public static function wrap(ptr:cpp.Pointer<Dynamic>):UClass {
    if (ptr == null) return null;
    return new UClass(ptr);
  }
}
