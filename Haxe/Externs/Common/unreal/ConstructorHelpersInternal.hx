package unreal;

@:glueCppIncludes("UObject/ConstructorHelpers.h")
@:uextern extern class ConstructorHelpersInternal {
  @:noTemplate
  @:uname("FindOrLoadObject<UObject>")
  public static function FindLoadObject<T : UObject>(PathName:PRef<FString>):T;

  @:noTemplate
  @:uname("FindOrLoadObject<UPackage>")
  public static function FindLoadObjectPackage(PathName:PRef<FString>):UPackage;

  public static function FindOrLoadClass(PathName:PRef<FString>, BaseClass:UClass):UClass;
}
