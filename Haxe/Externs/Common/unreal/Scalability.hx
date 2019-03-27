package unreal;

  /**
   * Structure for holding the state of the engine scalability groups
   * Actual engine state you can get though GetQualityLevels().
  **/
@:glueCppIncludes("Scalability.h")
@:uname("Scalability.FQualityLevels")
@:uextern extern class FQualityLevels
{
    public var ResolutionQuality : Int32;
    public var ViewDistanceQuality : Int32;
    public var AntiAliasingQuality : Int32;
    public var ShadowQuality : Int32;
    public var PostProcessQuality : Int32;
    public var TextureQuality : Int32;
    public var EffectsQuality : Int32;

    public function GetSingleQualityLevel() : Int32;

    // @param Value 0:low, 1:medium, 2:high, 3:epic
    public function SetFromSingleQualityLevel(Value:Int32) : Void;
}
