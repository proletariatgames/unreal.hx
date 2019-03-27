package unreal.stats;

@:glueCppIncludes("StatsFile.h")
@:noCopy @:noEquals
@:uextern extern class FCommandStatsFile
{
  public static function Get():PRef<FCommandStatsFile>;

  // public function Start(Filename:Const<PRef<FString>>):Void;

  // public function Stop():Void;

  public function IsStatFileActive():Bool;

  public var LastFileSaved:FString;
}
