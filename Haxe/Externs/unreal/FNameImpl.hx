package unreal;

@:glueCppIncludes("UObject/NameTypes.h")
@:uname("FName")
@:uextern extern class FNameImpl {
  // @:uname('new') static function create(text:FText):PHaxeCreated<FNameImpl>;
  function ToString():FString;

  function IsNone():Bool;
}
