package unreal;

@:glueCppIncludes("Containers/Map.h")
@:uname("TMap")
@:noEquals
@:uextern extern class TMap<K, V>
{
  @:uname('new') static function create<K, V>():PHaxeCreated<TMap<K, V>>;
  public function Add(InKey:K, InValue:V):V;
  public function FindOrAdd(Key:K):V;
  public function GetKeys(OutKeys:TArray<K>):Int32;
}