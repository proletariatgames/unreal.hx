package unreal;

@:build(ue4hx.internal.ExternGenerator.generate())
@:autoBuild(ue4hx.internal.ExternGenerator.generate())
@:uobject
@:glueCppIncludes("UObject/UObject.h")
class UObject
{
  private var wrapped:cpp.RawPointer<cpp.Void>;
  public function new(wrapped:cpp.Pointer<Dynamic>)
  {
    this.wrapped = wrapped.rawCast();
  }

  public function IsAsset():Bool;
  public function GetClass():UClass;
}

class UObject_Wrap {
  public static function wrap(ptr:cpp.Pointer<Dynamic>):UObject {
    if (ptr == null) return null;
    return new UObject(ptr);
  }
}

// import unreal.forward.UObject as UObject_Fwd;
// import unreal.forward.UClass as UClass_Fwd;
//
// @:uobject
// @:headerCode('class UObject;')
// class UObject
// {
//   private var wrapped:cpp.RawPointer<cpp.Void>;
//   private function new(native:cpp.Pointer<UObject_Fwd>)
//   {
//     this.wrapped = native.rawCast();
//   }
//
//   public function IsAsset():Bool
//   {
//     return UObject_Glue.IsAsset(cast wrapped);
//   }
//
//   public function GetClass():UClass
//   {
//     return UClass.wrap(cast UObject_Glue.GetClass(cast wrapped));
//   }
//
//   public function GetDesc():FString
//   {
//     return UObject_Glue.GetDesc(cast wrapped).toString();
//   }
//
//   public static function wrap(native:cpp.Pointer<UObject_Fwd>):Null<UObject>
//   {
//     if (native == null) return null;
//     return new UObject(native);
//   }
// }
//
// @:unrealGlue("UObject", "UObject/UObject.h")
// extern class UObject_Glue
// {
//   @:member public static function IsAsset(obj:cpp.RawPointer<UObject_Fwd>):Bool;
//   @:member public static function GetClass(obj:cpp.RawPointer<UObject_Fwd>):cpp.RawPointer<UClass_Fwd>;
//   @:member public static function GetDesc(obj:cpp.RawPointer<UObject_Fwd>):unreal.glue.FString;
// }
