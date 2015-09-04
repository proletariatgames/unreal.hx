import cpp.link.StaticStd;
import cpp.link.StaticRegexp;
import cpp.link.StaticZlib;
import unreal.UObject;

class UnrealInit
{
  static function main()
  {
    trace("hello world");
    var stat = unreal.UClass.StaticClass();
    trace('Found stat',stat == null);
    trace (stat.IsAsset());
    trace(stat.GetDesc());
    trace(stat.GetDefaultConfigFilename());
    trace('new');
  }
}
