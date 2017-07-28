package unreal;

@:glueCppIncludes("ConstructorHelpers.h")
@:uname("ConstructorHelpers.FObjectFinder")
@:typeName
@:uextern extern class FObjectFinderImpl<T> {
  @:uname(".ctor")
  @:typeName static function Find<T>(ObjectToFind:Const<TCharStar>) : FObjectFinderImpl<T>;

  function Succeeded() : Bool;
  var Object : PPtr<T>;
}

