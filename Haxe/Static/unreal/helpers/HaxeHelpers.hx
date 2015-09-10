package unreal.helpers;

@:unreflective class HaxeHelpers
{
  public static function dynamicToPointer(dyn:Dynamic):cpp.RawPointer<cpp.Void> {
    // there's no way to get a pointer to hxcpp's Dynamic struct
    // so we're using the undocumented GetPtr (defined in `include/hx/Object.h`)
    // this pointer should only be used in the stack - because this pointer will be
    // transparent to hxcpp - which might move the reference
    return untyped __cpp__('{0}.GetPtr()',dyn);
  }

  public static function pointerToDynamic(ptr:cpp.RawPointer<cpp.Void>):Dynamic {
    // see the comment above (at `dynamicToPointer`)
    var dyn:Dynamic = untyped __cpp__('Dynamic( (hx::Object *) {0} )', ptr);
    return dyn;
  }
}
