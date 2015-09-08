package unreal;

@:build(ue4hx.internal.ExternGenerator.generate())
@:autoBuild(ue4hx.internal.ExternGenerator.generate())
@:uobject
@:unrealExtern
@:glueCppIncludes("UObject/UObject.h")
class UObject
{
  @:skip private var wrapped:cpp.RawPointer<cpp.Void>;
  public function new(wrapped:cpp.Pointer<Dynamic>)
  {
    this.wrapped = wrapped.rawCast();
  }

  public function IsAsset():Bool;
  public function GetClass():UClass;
  public function GetDesc():FString;
  public function GetDefaultConfigFilename():FString;
  public function IsPostLoadThreadSafe():Bool;
  public function PostLoad():Void;
}

// We need this separate class because of a build order issue (HaxeFoundation/haxe#4527)
class UObject_Wrap {
  public static function wrap(ptr:cpp.Pointer<Dynamic>):UObject {
    if (ptr == null) return null;
    return new UObject(ptr);
  }
}
