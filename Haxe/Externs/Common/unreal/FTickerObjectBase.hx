package unreal;

@:glueCppIncludes("Ticker.h")
@:uextern @:noCopy @:noEquals extern class FTickerObjectBase
{
  function Tick(DeltaTime:Float32) : Bool;
}
