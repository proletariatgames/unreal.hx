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

  /**
    Same as `dynamicToPointer`, but is aware of variant pointers, and if `dyn` is a raw pointer, will return the unboxed pointer value instead
   **/
  @:ifFeature("unreal.helpers.HaxeHelpers.*") public static function variantToPointer(dyn:Dynamic):unreal.UIntPtr {
    var variant:VariantPtr = dyn;
    return untyped __cpp__('(unreal::UIntPtr) {0}.raw',variant);
  }

  @:extern inline public static function getUObjectWrapped(uobj:UObject):UIntPtr {
#if (cpp && !bake_externs)
    return (uobj == null ? 0 : @:privateAccess uobj.wrapped);
#else
    return 0;
#end
  }
}
