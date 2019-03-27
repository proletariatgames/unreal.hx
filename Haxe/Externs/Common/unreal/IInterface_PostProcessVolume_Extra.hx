package unreal;

extern class IInterface_PostProcessVolume_Extra
{
  public function EncompassesPoint(Point:FVector, SphereRadius:Float32 /*=0.f*/, OutDistanceToPoint:Ptr<Float32>):Bool;
  @:thisConst
	public function GetProperties():unreal.FPostProcessVolumeProperties;
}
