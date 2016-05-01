package unreal;

@:glueCppIncludes("UObject/NameTypes.h")
@:uname("FName")
@:uextern extern class FNameImpl {
  @:uname('new') static function create(text:TCharStar):POwnedPtr<FNameImpl>;
  @:uname('new') static function createFromInt(name:UnrealName):POwnedPtr<FNameImpl>;
  function ToString():FString;

  function IsNone():Bool;
  function GetComparisonIndex() : Int32;

  @:expr(return this.ToString().op_Dereference()) public function toString():String;
}
