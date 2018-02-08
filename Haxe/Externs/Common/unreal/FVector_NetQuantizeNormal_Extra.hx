package unreal;

@:hasCopy
extern class FVector_NetQuantizeNormal_Extra {
  @:uname(".ctor")
  public static function fromVector(vec:Const<PRef<FVector>>) : FVector_NetQuantizeNormal;
  @:uname("new")
  public static function fromVectorNew(vec:Const<PRef<FVector>>) : POwnedPtr<FVector_NetQuantizeNormal>;

  @:expr(return FVector.createWithValues(this.X, this.Y, this.Z))
  public function toVector() : FVector;

  @:op(A+B)
  @:expr(return FVector.createWithValues(this.X + b.X, this.Y + b.Y, this.Z + b.Z))
  public function _add(b:FVector):FVector;

  @:op(A+=B)
  @:expr(return { this.X += b.X; this.Y += b.Y; this.Z += b.Z; this; })
  public function _addeq(b:FVector):FVector;

  @:op(A*B)
  @:expr(return FVector.createWithValues(this.X * b, this.Y * b, this.Z * b))
  public function _mul(b:Float):FVector;

  @:op(A*=B)
  @:expr(return { this.X *= b; this.Y *= b; this.Z *= b; this; })
  public function _muleq(b:Float):FVector;

  @:op(A-B)
  @:expr(return FVector.createWithValues(this.X - b.X, this.Y - b.Y, this.Z - b.Z))
  public function _sub(b:FVector):FVector;

  @:op(A-=B)
  @:expr(return { this.X -= b.X; this.Y -= b.Y; this.Z -= b.Z; this; })
  public function _subeq(b:FVector):FVector;
}

