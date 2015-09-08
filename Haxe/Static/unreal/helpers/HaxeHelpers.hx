package unreal.helpers;

@:unreflective class HaxeHelpers
{
  public static function stringToPointer(str:String):cpp.RawPointer<cpp.Void> {
    // there's no way to get a pointer to hxcpp's Dynamic struct
    // so we're using the undocumented GetPtr (defined in `include/hx/Object.h`)
    // this pointer should only be used in the stack - because this pointer will be
    // transparent to hxcpp - which might move the reference
    var dyn:Dynamic = str;
    return untyped __cpp__('{0}.GetPtr()',dyn);
  }

  public static function pointerToString(ptr:cpp.RawPointer<cpp.Void>):String {
    // see the comment above (at `stringToPointer`)
    var dyn:Dynamic = untyped __cpp__('Dynamic( (hx::Object *) {0} )', ptr);
    return dyn;
  }
}
