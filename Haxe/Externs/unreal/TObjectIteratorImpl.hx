package unreal;

@:glueCppIncludes('EngineUtils.h')
@:uname("TObjectIterator")
@:uextern @:typeName extern class TObjectIteratorImpl<T> {
  @:uname('new') @:typeName public static function create<T>():PHaxeCreated<TObjectIterator<T>>;

  public function op_Increment() : Void;
  public function op_Dereference() : PExternal<T>;
  public function op_Not() : Bool;
}
