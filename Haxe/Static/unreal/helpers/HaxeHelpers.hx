package unreal.helpers;

@:unreflective class HaxeHelpers
{
  public static function stringToPointer(str:String):cpp.RawPointer<cpp.Void> {
    var dyn:Dynamic = str;
    // seems that there's no way to get a pointer to hxcpp's Dynamic struct
    // so we're using the undocumented GetPtr (defined in `include/hx/Object.h`)
    return untyped __cpp__('{0}.GetPtr()',dyn);
  }

  public static function pointerToString(ptr:cpp.RawPointer<cpp.Void>):String {
    var dyn:Dynamic = untyped __cpp__('Dynamic( (hx::Object *) {0} )', ptr);
    var str:String = dyn;
    return str;
  }
}
