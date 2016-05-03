package unreal;

@:glueCppIncludes('EngineUtils.h')
@:uname("TObjectIterator")
@:uextern @:typeName extern class TObjectIteratorImpl<T> {
  @:uname('.ctor') @:typeName public static function create<T>():TObjectIterator<T>;
  @:uname('new') @:typeName public static function createNew<T>():POwnedPtr<TObjectIterator<T>>;

  public function op_Increment() : Void;
  public function op_Dereference() : PPtr<T>;
  public function op_Not() : Bool;
}
