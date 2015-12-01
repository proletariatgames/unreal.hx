package unreal;

extern class FBox_Extra
{
  public var Min:FVector;
  public var Max:FVector;
  public var IsValid:UInt8;

  @:uname('new')
  public static function createForceInit(ForceInit:EForceInit) : PHaxeCreated<FBox>;
  @:uname('new')
  public static function createWithValues(Min:Const<PRef<FVector>>, Max:Const<PRef<FVector>>) : PHaxeCreated<FBox>;

  @:thisConst
  public function GetSize() : FVector;

  @:thisConst
  public function GetCenter() : FVector;
}
