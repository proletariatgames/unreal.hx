package unreal;

@:glueCppIncludes("ConstructorHelpers.h")
@:uname("ConstructorHelpers.FClassFinder")
@:typeName
@:uextern extern class FClassFinderImpl<T> {
  @:uname(".ctor")
  @:typeName static function Find<T>(ClassToFind:Const<TCharStar>) : FClassFinderImpl<T>;

  function Succeeded() : Bool;
  var Class : TSubclassOf<T>;
}
