package unreal;

@:glueCppIncludes("Logging/LogMacros.h")
@:uextern extern class FMsg {
  static function Logf(file:AnsiCharStar, line:Int, category:Const<PRef<FName>>, verbosity:ELogVerbosity, pattern:TCharStar, data:TCharStar):Void;
}