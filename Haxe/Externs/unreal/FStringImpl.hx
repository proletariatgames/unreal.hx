package unreal;

@:glueCppIncludes("Containers/UnrealString.h")
@:uname("FString")
@:uextern extern class FStringImpl {
  @:uname('new') static function create(text:TCharStar):POwnedPtr<FStringImpl>;
  function op_Dereference() : TCharStar;

  @:thisConst function IsEmpty() : Bool;
  @:thisConst function ToBool() : Bool;

  @:expr(return this.op_Dereference()) public function toString():String;
}

