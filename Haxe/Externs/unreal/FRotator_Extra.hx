package unreal;

extern class FRotator_Extra {

  @:uname('new') public static function createForceInit(e:EForceInit):POwnedPtr<FRotator>;

  @:uname('new') public static function createWithSingleValue(inF:Float32):POwnedPtr<FRotator>;

  @:uname('new') public static function createWithValues(inPitch:Float32, inYaw:Float32, inRoll:Float32):POwnedPtr<FRotator>;

  @:uname('new') public static function createFromQuat(quat:Const<PRef<FQuat>>):POwnedPtr<FRotator>;
  
  @:thisConst
  public function GetInverse() : FRotator;

  public var Pitch:Float32;
  public var Yaw:Float32;
  public var Roll:Float32;
}
