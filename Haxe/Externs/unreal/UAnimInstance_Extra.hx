package unreal;

extern class UAnimInstance_Extra {

  /**
    Returns the owning actor of this AnimInstance
   **/
  @:ufunction(BlueprintCallable, Category = "Animation")
  public function GetOwningActor() : AActor;

  /**
    Plays an animation montage. Returns the length of the animation montage in seconds. Returns 0.f if failed to play.
   **/
  @:ufunction(BlueprintCallable, Category = "Animation")
  public function Montage_Play(MontageToPlay:UAnimMontage, InPlayRate:Float32 = 1) : Float32;

  /**
    Stops the animation montage. If reference is NULL, it will stop ALL active montages.
   **/
  @:ufunction(BlueprintCallable, Category = "Animation")
  public function Montage_Stop(InBlendOutTime:Float32, Montage:UAnimMontage = null) : Void;

  /**
    Get Current Montage Position
   **/
  @:ufunction
  public function Montage_GetPosition(Montage:UAnimMontage) : Float32;

  /**
    Returns true if the animation montage is currently active and playing.
    If reference is NULL, it will return true is ANY montage is currently active and playing.
   **/
  @:ufunction(BlueprintCallable, Category="Animation")
  public function Montage_IsPlaying(Montage:UAnimMontage) : Bool;

  /**
    Set position.
   **/
  @:function
  public function Montage_SetPosition(Montage:UAnimMontage, NewPosition:Float32) : Void;

}
