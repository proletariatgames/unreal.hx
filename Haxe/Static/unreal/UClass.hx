package unreal;

@:glueCppIncludes("UObject/Class.h")
@:uobject
class UClass extends UObject
{
  public static function StaticClass():UClass;

  public static function wrap(t) {
    return new UClass(t);
  }
}

class UClass_Wrap {
  public static function wrap(ptr:cpp.Pointer<Dynamic>):UClass {
    if (ptr == null) return null;
    return new UClass(ptr);
  }
}

// import unreal.forward.UClass as UClass_Fwd;
//
// @:uobject
// @:headerCode('class UClass;')
// class UClass extends UObject
// {
//   private function new(native:cpp.Pointer<UClass_Fwd>)
//   {
//     super(native.reinterpret());
//   }
//
//   public static function StaticClass():UClass
//   {
//     return wrap(cpp.Pointer.fromRaw(UClass_Glue.StaticClass()));
//   }
//
//   public static function wrap(native:cpp.Pointer<UClass_Fwd>):Null<UClass>
//   {
//     if (native == null) return null;
//     if (UObject.UObject_Glue.GetClass(native.rawCast()) == UClass_Glue.StaticClass())
//       return new UClass(native);
//     // FIXME find in some class map
//     throw 'Not implemented';
//   }
// }
//
// @:unrealGlue("UClass", "UObject/Class.h")
// private extern class UClass_Glue
// {
//   public static function StaticClass():cpp.RawPointer<UClass_Fwd>;
// }
