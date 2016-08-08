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
#if (cpp && !bake_externs && !UHX_NO_UOBJECT)
    return (uobj == null ? 0 : @:privateAccess uobj.wrapped);
#else
    return 0;
#end
  }

  @:extern inline public static function checkPointer(struct:Struct, fieldName:String) {
#if (debug || UHX_CHECK_POINTER)
    if (struct == null) {
      throw 'Cannot access field "$fieldName" of null';
    }
#end
  }

  public static function nullDeref(name:String) {
    throw 'Cannot dereference null "$name"';
  }

  @:extern inline public static function checkObjectPointer(obj:UObject, fieldName:String) {
#if (cpp && !bake_externs && !UHX_NO_UOBJECT && (debug || UHX_CHECK_POINTER))
    if (@:privateAccess obj.wrapped == 0) {
      throw 'Cannot access field "$fieldName" of a garbage collected object. Please check if the object is valid first';
    }
#end
  }
}
