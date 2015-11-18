package unreal;

@:glueCppIncludes("ConstructorHelpers.h")
@:uname("ConstructorHelpers.FClassFinder")
@:typeName
@:uextern extern class FClassFinder<T> {
  @:uname("new")
  @:typeName static function Find<T>(ClassToFind:Const<TCharStar>) : PHaxeCreated<FClassFinder<T>>;

  function Succeeded() : Bool;
  var Class : TSubclassOf<T>;
}
