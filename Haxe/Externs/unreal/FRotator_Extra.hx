package unreal;

extern class FRotator_Extra {

  @:uname('new') public static function createForceInit(e:EForceInit):PHaxeCreated<FRotator>;

  @:uname('new') public static function createWithSingleValue(inF:Float32):PHaxeCreated<FRotator>;

  @:uname('new') public static function createWithValues(inPitch:Float32, inYaw:Float32, inRoll:Float32):PHaxeCreated<FRotator>;

  @:uname('new') public static function createFromQuat(quat:Const<PRef<FQuat>>):PHaxeCreated<FRotator>;
  
  @:thisConst
  public function GetInverse() : FRotator;

  public var Pitch:Float32;
  public var Yaw:Float32;
  public var Roll:Float32;
}
