package unreal;

/**
 **/
@:unrealType
@:forward
abstract TSubclassOf<T>(UClass) from UClass to UClass
{
  inline public function Get()
  {
    return this;
  }

  @:from inline public static function FromOther<A, B>(Subclass:TSubclassOf<A>):TSubclassOf<B>
  {
    return Subclass.Get();
  }
}
