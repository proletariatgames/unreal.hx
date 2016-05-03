package unreal.helpers;
import unreal.Wrapper;

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

  public static function createInlinePodWrapper(size:Int) : VariantPtr {
    return VariantPtr.fromDynamic( InlinePodWrapper.create(size) );
  }

  public static function createInlineWrapper(size:Int) : VariantPtr {
    return VariantPtr.fromDynamic( InlineWrapper.create(size) );
  }

  @:native("callFunction")
  public static function callFunction0(ptr:UIntPtr) : UIntPtr {
    return toPtr( toDyn(ptr)() );
  }
  @:native("callFunction")
  public static function callFunction1(ptr:UIntPtr, arg0:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0)) );
  }
  @:native("callFunction")
  public static function callFunction2(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1)) );
  }
  @:native("callFunction")
  public static function callFunction3(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2)) );
  }
  @:native("callFunction")
  public static function callFunction4(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3)) );
  }
  @:native("callFunction")
  public static function callFunction5(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4)) );
  }
  @:native("callFunction")
  public static function callFunction6(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5)) );
  }
  @:native("callFunction")
  public static function callFunction7(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr, arg6:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6)) );
  }
  @:native("callFunction")
  public static function callFunction8(ptr:UIntPtr, arg0:UIntPtr, arg1:UIntPtr, arg2:UIntPtr, arg3:UIntPtr, arg4:UIntPtr, arg5:UIntPtr, arg6:UIntPtr, arg7:UIntPtr) : UIntPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6), toDyn(arg7)) );
  }
}

