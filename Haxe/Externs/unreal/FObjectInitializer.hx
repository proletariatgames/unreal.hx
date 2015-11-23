package unreal;

@:glueCppIncludes("Engine.h")
@:noCopy @:noEquals @:uextern extern class FObjectInitializer {
  public static function Get() : PRef<FObjectInitializer>;

  @:thisConst
  @:typeName public function CreateDefaultSubobject<T>(Outer:UObject, SubojectName:FName, bTransient:Bool) : PExternal<T>;

  @:thisConst
  @:typeName public function SetDefaultSubobjectClass<T>(SubojectName:FName) : Const<PRef<FObjectInitializer>>;
}