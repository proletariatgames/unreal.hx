package unreal;

@:glueCppIncludes("ConstructorHelpers.h")
@:uname("ConstructorHelpers.FObjectFinder")
@:typeName
@:uextern extern class FObjectFinder<T> {
  @:uname("new")
  @:typeName static function Find<T>(ObjectToFind:Const<TCharStar>) : POwnedPtr<FObjectFinder<T>>;

  function Succeeded() : Bool;
  var Object : PPtr<T>;
}

