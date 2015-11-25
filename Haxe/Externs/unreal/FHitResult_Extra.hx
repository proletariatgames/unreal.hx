package unreal;

extern class FHitResult_Extra {
  @:uname('new')
  public static function createForceInit(init:EForceInit) : PHaxeCreated<FHitResult>;

  public var Actor:TWeakObjectPtr<AActor>;
  public var PhysMaterial:TWeakObjectPtr<UPhysicalMaterial>;
  public var Component:TWeakObjectPtr<UPrimitiveComponent>;
}
