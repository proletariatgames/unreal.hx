package unreal.helpers;
import unreal.Wrapper;

@:headerClassCode('
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr) { callFunction0(ptr); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0) { callFunction1(ptr, arg0); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1) { callFunction2(ptr, arg0, arg1); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2) { callFunction3(ptr, arg0, arg1, arg2); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3) { callFunction4(ptr, arg0, arg1, arg2, arg3); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4) { callFunction5(ptr, arg0, arg1, arg2, arg3, arg4); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4, unreal::UIntPtr arg5) { callFunction6(ptr, arg0, arg1, arg2, arg3, arg4, arg5); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4, unreal::UIntPtr arg5, unreal::UIntPtr arg6) { callFunction7(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6); }
  inline static unreal::UIntPtr callFunction(unreal::UIntPtr ptr, unreal::UIntPtr arg0, unreal::UIntPtr arg1, unreal::UIntPtr arg2, unreal::UIntPtr arg3, unreal::UIntPtr arg4, unreal::UIntPtr arg5, unreal::UIntPtr arg6, unreal::UIntPtr arg7) { callFunction8(ptr, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7); }
')
@:uexpose @:keep class HxcppRuntimeStatic
{
  @:extern static inline function toDyn(ptr:UIntPtr) return HaxeHelpers.pointerToDynamic(ptr);
  @:extern static inline function toPtr(dyn:Dynamic) return HaxeHelpers.dynamicToPointer(dyn);

  public static function constCharToString(str:cpp.ConstCharStar):UIntPtr {
    return toPtr(str.toString());
  }
  public static function stringToConstChar(ptr:UIntPtr):cpp.ConstCharStar {
    return cpp.ConstCharStar.fromString( toDyn(ptr) );
  }

  @:void public static function throwString(str:cpp.ConstCharStar):Void {
    throw str.toString();
  }

  public static function createInlinePodWrapper(size:Int, info:UIntPtr) : VariantPtr {
    return VariantPtr.fromDynamic( InlinePodWrapper.create(size, info) );
  }

  public static function createInlineWrapper(size:Int, info:UIntPtr) : VariantPtr {
    return VariantPtr.fromDynamic( InlineWrapper.create(size, info) );
  }

  public static function callFunction0(ptr:UIntPtr) : UIntPtr {
    return toPtr( toDyn(ptr)() );
  }
  public static function callFunction1(ptr:UIntPtr, arg0:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0)) );
  }
  public static function callFunction2(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1)) );
  }
  public static function callFunction3(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2)) );
  }
  public static function callFunction4(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3)) );
  }
  public static function callFunction5(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4)) );
  }
  public static function callFunction6(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5)) );
  }
  public static function callFunction7(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr, arg6:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6)) );
  }
  public static function callFunction8(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr, arg6:UIntPtr, arg7:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6), toDyn(arg7)) );
  }
}

