package unreal;

@:glueCppIncludes("Interfaces/Interface_PostProcessVolume.h") @:uextern extern class FPostProcessVolumeProperties
{
  public var Settings:PPtr<Const<unreal.FPostProcessSettings>>;
	public var Priority:unreal.Float32;
	public var BlendRadius:unreal.Float32;
	public var BlendWeight:unreal.Float32;
	public var bIsEnabled:Bool;
	public var bIsUnbound:Bool;

	@:uname(".ctor") public static function create():FPostProcessVolumeProperties;
}
