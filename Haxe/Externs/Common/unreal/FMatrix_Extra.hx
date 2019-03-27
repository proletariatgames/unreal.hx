package unreal;

extern class FMatrix_Extra {
   public function new(InX:Const<PRef<FVector>>, InY:Const<PRef<FVector>>, InZ:Const<PRef<FVector>>, InW:Const<PRef<FVector>>);

  /**
   * get axis of this matrix scaled by the scale of the matrix
   *
   * @param i index into the axis of the matrix
   * @ return vector of the axis
   */
  @:thisConst
  public function GetScaledAxis(Axis:EAxis) : FVector;

  /** @return rotator representation of this matrix */
  @:thisConst
  public function Rotator() : FRotator;
}
