package unreal;

@:unrealType
@:forward
abstract TEnumAsByte<T>(T) from T to T {
  inline public function GetValue():T
  {
    return this;
  }
}