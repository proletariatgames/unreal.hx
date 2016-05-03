package unreal;

extern class FRotator_Extra {

  @:uname('.ctor') public static function createForceInit(e:EForceInit):FRotator;
  @:uname('new') public static function createNewForceInit(e:EForceInit):POwnedPtr<FRotator>;

  @:uname('.ctor') public static function createWithSingleValue(inF:Float32):FRotator;
  @:uname('new') public static function createNewWithSingleValue(inF:Float32):POwnedPtr<FRotator>;

  @:uname('.ctor') public static function createWithValues(inPitch:Float32, inYaw:Float32, inRoll:Float32):FRotator;
  @:uname('new') public static function createNewWithValues(inPitch:Float32, inYaw:Float32, inRoll:Float32):POwnedPtr<FRotator>;

  @:uname('.ctor') public static function createFromQuat(quat:Const<PRef<FQuat>>):FRotator;
  @:uname('new') public static function createNewFromQuat(quat:Const<PRef<FQuat>>):POwnedPtr<FRotator>;

  @:thisConst
  public function GetInverse() : FRotator;

  public var Pitch:Float32;
  public var Yaw:Float32;
  public var Roll:Float32;
}
