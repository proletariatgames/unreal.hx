package unreal;

extern class FHitResult_Extra {
  public function new(init:EForceInit);

  @:uname('.ctor')
  public static function createWithValues(Actor:AActor, Component:UPrimitiveComponent, HitLoc:PRef<Const<FVector>>, HitNorm:PRef<Const<FVector>>) : FHitResult;
  @:uname('.ctor')
  public static function createForceInit(init:EForceInit) : FHitResult;

  @:uname('new')
  public static function createNewForceInit(init:EForceInit) : POwnedPtr<FHitResult>;

  /** Reset hit result while optionally saving TraceStart and TraceEnd. */
  public function Reset(InTime:Float32 = 1., bPreserveTraceData:Bool = true) : Void;
}
