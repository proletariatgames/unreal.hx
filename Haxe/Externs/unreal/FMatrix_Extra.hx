package unreal;

extern class FMatrix_Extra {
  /**
   * get axis of this matrix scaled by the scale of the matrix
   *
   * @param i index into the axis of the matrix
   * @ return vector of the axis
   */
  @:thisConst
  public function GetScaledAxis(Axis:EAxis) : FVector;
}
