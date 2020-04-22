package unreal;


@:glueCppIncludes('UObject/SoftObjectPtr.h')
@:typeName
@:uextern extern class TSoftClassPtr<T> {

  @:uname('.ctor') public static function create<T>():TSoftClassPtr<T>;

  public function Get() : UClass;

  public function ToSoftObjectPath() : Const<PRef<FSoftObjectPath>>;
}
