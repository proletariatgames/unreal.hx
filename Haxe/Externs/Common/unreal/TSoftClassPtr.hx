package unreal;


@:glueCppIncludes('UObject/SoftObjectPtr.h')
@:typeName
@:uextern extern class TSoftClassPtr<T : UObject> {

  @:uname('.ctor') public static function create<T : UObject>():TSoftClassPtr<T>;

  @:uname('.ctor') public static function createWithClass<T : UObject>(Cls:UClass):TSoftClassPtr<T>;

  public function Get() : UClass;

  @:uname('op_Assign') public function Set(val:UClass):Void;

  public function ToSoftObjectPath() : Const<PRef<FSoftObjectPath>>;

  @:thisConst public function LoadSynchronous() : UClass;
}
