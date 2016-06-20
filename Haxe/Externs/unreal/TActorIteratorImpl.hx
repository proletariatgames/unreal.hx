package unreal;

@:glueCppIncludes('EngineUtils.h')
@:uname("TActorIterator")
@:uextern @:typeName extern class TActorIteratorImpl<T> {
  @:uname('.ctor') @:typeName public static function create<T>(world:UWorld):TActorIterator<T>;
  @:uname('.ctor') @:typeName public static function createForSubclass<T>(world:UWorld, subclass:TSubclassOf<T>):TActorIterator<T>;
  @:uname('new') @:typeName public static function createNew<T>(world:UWorld):POwnedPtr<TActorIterator<T>>;

  public function op_Increment() : Void;
  public function op_Dereference() : PPtr<T>;
  public function op_Not() : Bool;
}
