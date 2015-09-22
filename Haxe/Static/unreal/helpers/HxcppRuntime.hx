package unreal.helpers;

@:uexpose @:keep class HxcppRuntime
{
  public static function constCharToString(str:cpp.ConstCharStar):cpp.RawPointer<cpp.Void> {
    return HaxeHelpers.dynamicToPointer(str.toString());
  }
  public static function stringToConstChar(ptr:cpp.RawPointer<cpp.Void>):cpp.ConstCharStar {
    return cpp.ConstCharStar.fromString( HaxeHelpers.pointerToDynamic(ptr) );
  }

  @:void public static function throwString(str:cpp.ConstCharStar):Void {
    throw str.toString();
  }

  public static function getWrapped(ptr:cpp.RawPointer<cpp.Void>):cpp.RawPointer<cpp.Void> {
    var dyn:{ function reflectGetWrapped():cpp.Pointer<Dynamic>; } =
      HaxeHelpers.pointerToDynamic(ptr);

    var ret:cpp.Pointer<Dynamic>;
    if (dyn == null) {
      ret = null;
    } else {
      ret = dyn.reflectGetWrapped();
    }

    return ret.rawCast();
  }
}

