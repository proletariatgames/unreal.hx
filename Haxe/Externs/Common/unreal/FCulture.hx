package unreal;

@:glueCppIncludes("Internationalization/Culture.h")
@:uname("FCulture")
@:uextern extern class FCulture {
  static function Create(localeName:Const<PRef<FString>>):TThreadSafeSharedPtr<FCulture>;
  function GetRegion():Const<PRef<FString>>;
}


