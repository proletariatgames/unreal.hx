package unreal;

@:glueCppIncludes("UObject/NameTypes.h")
@:uname("FName")
@:ustruct
@:uextern extern class FNameImpl {
  @:uname('.ctor') static function create(text:TCharStar):FNameImpl;
  @:uname('new') static function createNew(text:TCharStar):POwnedPtr<FNameImpl>;
  @:uname('.ctor') static function createFromInt(name:UnrealName):FNameImpl;
  @:uname('new') static function createNewFromInt(name:UnrealName):POwnedPtr<FNameImpl>;
  function ToString():FString;

  function IsNone():Bool;
  function GetComparisonIndex() : Int32;

  @:expr(return ToString().op_Dereference()) public function toString():String;
}
