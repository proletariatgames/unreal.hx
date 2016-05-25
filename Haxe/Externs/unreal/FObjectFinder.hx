package unreal;

@:glueCppIncludes("ConstructorHelpers.h")
@:uname("ConstructorHelpers.FObjectFinder")
@:typeName
@:uextern extern class FObjectFinder<T> {
  @:uname(".ctor")
  @:typeName static function Find<T>(ObjectToFind:Const<TCharStar>) : FObjectFinder<T>;

  function Succeeded() : Bool;
  var Object : PPtr<T>;
}

