package unreal;

@:glueCppIncludes("Containers/Map.h")
@:uname("TMap")
@:noEquals
@:uextern extern class TMap<K, V>
{
  @:uname('.ctor') static function create<K, V>():TMap<K, V>;
  @:uname('new') static function createNew<K, V>():POwnedPtr<TMap<K, V>>;
  public function Add(InKey:K, InValue:V):V;
  public function FindOrAdd(Key:K):V;
  public function GetKeys(OutKeys:TArray<K>):Int32;
  public function Contains(InKey:K):Bool;
  public function FindChecked(InKey:K):PRef<V>;
  public function Remove(InKey:K):Int32;
}
