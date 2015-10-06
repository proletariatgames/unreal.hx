package unreal.helpers;

@:unrealGlue extern class FName_Glue {
  public static function from_string(str:cpp.RawPointer<cpp.Void>):cpp.RawPointer<UEPointer>;
}


