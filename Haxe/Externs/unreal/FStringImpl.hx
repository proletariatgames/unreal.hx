package unreal;

@:glueCppIncludes("Containers/UnrealString.h")
@:uname("FString")
@:uextern extern class FStringImpl {
  @:uname('.ctor') static function create(text:TCharStar):FStringImpl;
  @:uname('new') static function createNew(text:TCharStar):POwnedPtr<FStringImpl>;
  function op_Dereference() : TCharStar;

  @:thisConst function IsEmpty() : Bool;
  @:thisConst function ToBool() : Bool;

  @:expr(return op_Dereference()) public function toString():String;
}

