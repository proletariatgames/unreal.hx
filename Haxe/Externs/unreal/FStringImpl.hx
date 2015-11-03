package unreal;

@:glueCppIncludes("Containers/UnrealString.h")
@:uname("FString")
@:uextern extern class FStringImpl {
  @:uname('new') static function create(text:TCharStar):PHaxeCreated<FStringImpl>;
  function op_Dereference() : TCharStar;
}

