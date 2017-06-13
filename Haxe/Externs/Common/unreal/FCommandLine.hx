package unreal;

@:glueCppIncludes("Misc/CoreMisc.h")
@:uextern extern class FCommandLine {
  static function Get():TCharStar;
  static function Set(NewCommandLine:Const<TCharStar>):Bool;
}
