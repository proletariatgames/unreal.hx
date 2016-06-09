package unreal;

@:glueCppIncludes('HAL/PlatformProcess.h')
@:uextern extern class FPlatformProcess {

  public static function LaunchURL(URL:Const<TCharStar>, Parms:Const<TCharStar>, Error:PPtr<FString>):Void;
}
