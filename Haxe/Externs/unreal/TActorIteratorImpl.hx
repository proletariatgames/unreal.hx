package unreal;

@:glueCppIncludes('EngineUtils.h')
@:uname("TActorIterator")
@:uextern @:typeName extern class TActorIteratorImpl<T> {
  @:uname('new') @:typeName public static function create<T>(world:UWorld):PHaxeCreated<TActorIterator<T>>;

  public function op_Increment() : Void;
  public function op_Dereference() : PExternal<T>;
  public function op_Not() : Bool;
}
