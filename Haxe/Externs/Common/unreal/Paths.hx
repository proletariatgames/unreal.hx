package unreal;

@:glueCppIncludes("Paths.h")
@:uname("FPaths")
@:uextern extern class Paths {
  public static function GetBaseFilename(InPath:Const<PRef<FString>>, bRemovePath:Bool) : FString;
}