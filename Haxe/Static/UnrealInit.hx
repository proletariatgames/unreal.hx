import cpp.link.StaticStd;
import cpp.link.StaticRegexp;
import cpp.link.StaticZlib;
import unreal.UObject;

class UnrealInit
{
  static function main()
  {
    trace("hello world");
    trace (unreal.UClass.StaticClass().IsAsset());
  }
}
