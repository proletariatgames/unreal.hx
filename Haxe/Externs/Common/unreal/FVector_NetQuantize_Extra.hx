package unreal;

@:hasCopy
extern class FVector_NetQuantize_Extra {
  public function new();
  @:uname('.ctor') public static function create() : FVector_NetQuantize;
  @:uname('.ctor') public static function createFromVector(Vec:Const<PRef<FVector>>) : FVector_NetQuantize;

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
