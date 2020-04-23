package unreal;


@:glueCppIncludes('UObject/SoftObjectPtr.h')
@:typeName
@:uextern extern class TSoftObjectPtr<T : UObject> {

  @:uname('.ctor') public static function create<T : UObject>():TSoftObjectPtr<T>;

  @:uname('.ctor') public static function createWithObject<T : UObject>(Object:T):TSoftObjectPtr<T>;

  public function Get() : UObject;

  @:uname('op_Assign') public function Set(val:PPtr<T>):Void;

  public function ToSoftObjectPath() : Const<PRef<FSoftObjectPath>>;
}
