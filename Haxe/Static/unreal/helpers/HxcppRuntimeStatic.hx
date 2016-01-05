package unreal.helpers;

private typedef VoidPtr = cpp.RawPointer<cpp.Void>;

@:uexpose @:keep class HxcppRuntimeStatic
{
  @:extern static inline function toDyn(ptr:VoidPtr) return HaxeHelpers.pointerToDynamic(ptr);
  @:extern static inline function toPtr(dyn:Dynamic) return HaxeHelpers.dynamicToPointer(dyn);

  public static function constCharToString(str:cpp.ConstCharStar):VoidPtr {
    return toPtr(str.toString());
  }
  public static function stringToConstChar(ptr:VoidPtr):cpp.ConstCharStar {
    return cpp.ConstCharStar.fromString( toDyn(ptr) );
  }

  @:void public static function throwString(str:cpp.ConstCharStar):Void {
    throw str.toString();
  }

  public static function getWrapped(ptr:VoidPtr):VoidPtr {
    var dyn:Dynamic = toDyn(ptr);
    var ret:VoidPtr = untyped __cpp__('(void *) 0');
    if (dyn != null) {
      if (Std.is(dyn, UObject)) {
        var uobj:UObject = dyn;
        ret = @:privateAccess uobj.getWrapped().rawCast();
      } else if (Std.is(dyn, Wrapper)) {
        var wrapper:Wrapper = dyn;
        ret = @:privateAccess wrapper.getWrapped().rawCast();
      } else {
        throw 'Unknown object type: $dyn (${Type.getClassName(Type.getClass(dyn))})';
      }
    }
    return ret;
  }

  public static function getWrappedRef(ptr:VoidPtr) : VoidPtr {
    var dyn:Dynamic = toDyn(ptr);
    var ret:VoidPtr = untyped __cpp__('(void *) 0');
    if (dyn != null) {
      if (Std.is(dyn, UObject)) {
        var uobj:UObject = dyn;
        ret = @:privateAccess uobj.getWrappedAddr().rawCast();
      } else if (Std.is(dyn, Wrapper)) {
        var wrapper:Wrapper = dyn;
        ret = @:privateAccess cpp.Pointer.addressOf(wrapper.wrapped).rawCast();
      } else {
        throw 'Unknown object type: $dyn (${Type.getClassName(Type.getClass(dyn))})';
      }
    }
    return ret;
  }

  @:native("callFunction")
  public static function callFunction0(ptr:VoidPtr) : VoidPtr {
    return toPtr( toDyn(ptr)() );
  }
  @:native("callFunction")
  public static function callFunction1(ptr:VoidPtr, arg0:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0)) );
  }
  @:native("callFunction")
  public static function callFunction2(ptr:VoidPtr, arg0:VoidPtr, arg1:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1)) );
  }
  @:native("callFunction")
  public static function callFunction3(ptr:VoidPtr, arg0:VoidPtr, arg1:VoidPtr, arg2:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2)) );
  }
  @:native("callFunction")
  public static function callFunction4(ptr:VoidPtr, arg0:VoidPtr, arg1:VoidPtr, arg2:VoidPtr, arg3:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3)) );
  }
  @:native("callFunction")
  public static function callFunction5(ptr:VoidPtr, arg0:VoidPtr, arg1:VoidPtr, arg2:VoidPtr, arg3:VoidPtr, arg4:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4)) );
  }
  @:native("callFunction")
  public static function callFunction6(ptr:VoidPtr, arg0:VoidPtr, arg1:VoidPtr, arg2:VoidPtr, arg3:VoidPtr, arg4:VoidPtr, arg5:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5)) );
  }
  @:native("callFunction")
  public static function callFunction7(ptr:VoidPtr, arg0:VoidPtr, arg1:VoidPtr, arg2:VoidPtr, arg3:VoidPtr, arg4:VoidPtr, arg5:VoidPtr, arg6:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6)) );
  }
  @:native("callFunction")
  public static function callFunction8(ptr:VoidPtr, arg0:VoidPtr, arg1:VoidPtr, arg2:VoidPtr, arg3:VoidPtr, arg4:VoidPtr, arg5:VoidPtr, arg6:VoidPtr, arg7:VoidPtr) : VoidPtr {
    return toPtr( (toDyn(ptr))(toDyn(arg0), toDyn(arg1), toDyn(arg2), toDyn(arg3), toDyn(arg4), toDyn(arg5), toDyn(arg6), toDyn(arg7)) );
  }
}

