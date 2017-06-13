package unreal;

@:glueCppIncludes("Misc/Parse.h")
@:uextern extern class FParse {
  static function Value(Stream:Const<TCharStar>, Match:Const<TCharStar>, Value:PRef<FString>, ?bShouldStopOnComma:Bool=true):Bool;
  static function Param(Stream:Const<TCharStar>, Param:Const<TCharStar>):Bool;
}