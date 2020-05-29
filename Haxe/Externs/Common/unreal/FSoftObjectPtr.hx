package unreal;


@:glueCppIncludes('UObject/SoftObjectPtr.h')
@:typeName
@:uextern extern class FSoftObjectPtr {

  @:uname('.ctor') public static function create():FSoftObjectPtr;

  @:uname('.ctor') public static function createWithObject(Object:UObject):FSoftObjectPtr;

  public function Get() : UObject;

  public function ToSoftObjectPath() : Const<PRef<FSoftObjectPath>>;
}