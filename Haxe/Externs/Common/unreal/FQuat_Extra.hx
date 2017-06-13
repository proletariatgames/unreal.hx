package unreal;

extern class FQuat_Extra {
  @:uname('.ctor') public static function create() : FQuat;
  @:uname('new') public static function createNew() : POwnedPtr<FQuat>;
  @:uname('.ctor') public static function createFromRotator(rotator:Const<PRef<FRotator>>) : FQuat;
  @:uname('new') public static function createNewFromRotator(rotator:Const<PRef<FRotator>>) : POwnedPtr<FQuat>;

  public static var Identity(default, never):FQuat;
}
