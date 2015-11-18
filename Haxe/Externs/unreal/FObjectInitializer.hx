package unreal;

typedef Foo<T> = Const<PRef<FObjectInitializer>>;

@:glueCppIncludes("Engine.h")
@:noCopy @:noEquals @:uextern extern class FObjectInitializer {
  public static function Get() : PRef<FObjectInitializer>;

  @:thisConst
  @:typeName public function CreateDefaultSubobject<T>(Outer:UObject, SubojectName:FName, bTransient:Bool) : PExternal<T>;

  @:thisConst
  @:typeName public function SetDefaultSubobjectClass<T>(SubojectName:FName) : Foo<T>;
}