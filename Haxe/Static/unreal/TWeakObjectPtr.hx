package unreal;

@:unrealType
@:forward abstract TWeakObjectPtr<T : UObject>(T) from T to T
{
  inline public function Get()
  {
    return this;
  }
}