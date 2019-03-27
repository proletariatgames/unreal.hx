package unreal;

extern class UGameplayStatics_Extra {
#if proletariat
	@:ufunction(BlueprintCallable) @:uname("PlaySoundAtLocation")
	static public function PlaySoundAtLocationWithOwner(WorldContextObject : unreal.Const<unreal.UObject>, Sound : unreal.USoundBase, Location : unreal.FVector, Rotation : unreal.FRotator, VolumeMultiplier : unreal.Float32 = 1.000000, PitchMultiplier : unreal.Float32 = 1.000000, StartTime : unreal.Float32 = 0.000000, AttenuationSettings : unreal.USoundAttenuation, ConcurrencySettings : unreal.USoundConcurrency, OwningActor : unreal.AActor) : Void;
#end
}
