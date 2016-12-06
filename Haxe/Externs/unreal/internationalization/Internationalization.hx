package unreal.internationalization;

@:global
@:nocopy @:noEquals
@:glueCppIncludes("Internationalization.h")
@:uname("FInternationalization")
@:uextern extern class FInternationalization {

  public static function Get() : PRef<FInternationalization>;
  public function SetCurrentCulture(Name:PRef<FString>) : Bool;
  public function GetCurrentCulture() : FCultureRef;
}