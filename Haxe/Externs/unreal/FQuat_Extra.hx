package unreal;

extern class FQuat_Extra {
  @:uname('new') public static function create() : PHaxeCreated<FQuat>;
  @:uname('new') public static function createFromRotator(rotator:Const<PRef<FRotator>>) : PHaxeCreated<FQuat>;
}