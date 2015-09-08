package unreal.helpers;

@:ue4expose @:keep @:nativeGen class HxcppRuntime
{
  public static function constCharToString(str:cpp.ConstCharStar):cpp.RawPointer<cpp.Void> {
    return HaxeHelpers.stringToPointer(str);
  }
  public static function stringToConstChar(ptr:cpp.RawPointer<cpp.Void>):cpp.ConstCharStar {
    return cpp.ConstCharStar.fromString( HaxeHelpers.pointerToString(ptr) );
  }
}

