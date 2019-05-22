package unreal;

#if (UE_VER >= 4.22)
@:glueCppIncludes("Misc/Optional.h")
@:uextern extern class TOptional<T>
{
	@:uname('.ctor') public static function create<T>(value:PRef<Const<T>>):TOptional<T>;
	@:uname('.ctor') public static function createEmpty<T>() : TOptional<T>;
}
#end
