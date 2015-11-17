package unreal;

@:glueCppIncludes("UObject/NameTypes.h")
@:uname("FName")
@:uextern extern class FNameImpl {
  @:uname('new') static function create(text:TCharStar):PHaxeCreated<FNameImpl>;
  @:uname('new') static function createFromInt(name:UnrealName):PHaxeCreated<FNameImpl>;
  function ToString():FString;

  function IsNone():Bool;
}
