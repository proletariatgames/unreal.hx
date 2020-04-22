package unreal;


@:glueCppIncludes('UObject/SoftObjectPtr.h')
@:typeName
@:uextern extern class TSoftObjectPtr<T> {

  @:uname('.ctor') public static function create<T>():TSoftObjectPtr<T>;

  public function Get() : UObject;

  public function ToSoftObjectPath() : Const<PRef<FSoftObjectPath>>;
}
