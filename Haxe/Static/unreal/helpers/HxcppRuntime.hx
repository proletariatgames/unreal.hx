package unreal.helpers;

@:ue4expose
@:keep
@:nativeGen class HxcppRuntime
{
  public static function constCharToString(str:cpp.ConstCharStar):String {
    return str.toString();
  }
  public static function stringToConstChar(str:String):cpp.ConstCharStar {
    return cpp.ConstCharStar.fromString(str);
  }
}

