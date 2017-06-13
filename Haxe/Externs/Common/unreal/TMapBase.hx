package unreal;

@:glueCppIncludes("Containers/Map.h")
@:uname("TMapBase")
@:noEquals
@:uextern extern class TMapBase<K, V>
{
    public function Add(InKey:K, InValue:V):V;
    public function FindOrAdd(Key:K):V;
    public function GetKeys(OutKeys:TArray<K>):Int32;
}
