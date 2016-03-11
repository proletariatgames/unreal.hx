package unreal;

extern class UAnimInstance_Extra {

  /**
    Get Current Montage Position
   **/
  @:ufunction
  public function Montage_GetPosition(Montage:UAnimMontage) : Float32;

  /**
    Set position.
   **/
  @:function
  public function Montage_SetPosition(Montage:UAnimMontage, NewPosition:Float32) : Void;

  public function NativeUpdateAnimation(deltaSeconds:Float32) : Void;
}
