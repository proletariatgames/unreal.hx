package unreal;

@:unrealType
@:forward abstract TAutoWeakObjectPtr<T : UObject>(T) from T to T
{
  inline public function Get()
  {
    return this;
  }
}
