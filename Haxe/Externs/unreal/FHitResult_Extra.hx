package unreal;

extern class FHitResult_Extra {
  @:uname('.ctor')
  public static function createForceInit(init:EForceInit) : FHitResult;

  @:uname('new')
  public static function createNewForceInit(init:EForceInit) : POwnedPtr<FHitResult>;

  public var Actor:TWeakObjectPtr<AActor>;
  public var PhysMaterial:TWeakObjectPtr<UPhysicalMaterial>;
  public var Component:TWeakObjectPtr<UPrimitiveComponent>;
}
