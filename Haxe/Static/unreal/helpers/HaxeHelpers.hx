package unreal.helpers;

@:unreflective class HaxeHelpers
{
  @:ifFeature("unreal.helpers.HaxeHelpers.*") public static function dynamicToPointer(dyn:Dynamic):unreal.UIntPtr {
    // there's no way to get a pointer to hxcpp's Dynamic struct
    // so we're using the undocumented GetPtr (defined in `include/hx/Object.h`)
    // this pointer should only be used in the stack - because this pointer will be
    // transparent to hxcpp - which might move the reference
    var dyn:Dynamic = dyn;
    return untyped __cpp__('(unreal::UIntPtr) {0}.GetPtr()',dyn);
  }

  @:ifFeature("unreal.helpers.HaxeHelpers.*") public static function pointerToDynamic(ptr:unreal.UIntPtr):Dynamic {
    var dyn:Dynamic = untyped __cpp__('Dynamic( (hx::Object *) {0} )', ptr);
    return dyn;
  }
}
