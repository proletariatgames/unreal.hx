package unreal;

@:glueCppIncludes("ConstructorHelpers.h")
@:uname("ConstructorHelpers.FClassFinder")
@:typeName
@:uextern extern class FClassFinder<T> {
  @:uname(".ctor")
  @:typeName static function Find<T>(ClassToFind:Const<TCharStar>) : FClassFinder<T>;

  function Succeeded() : Bool;
  var Class : TSubclassOf<T>;
}
