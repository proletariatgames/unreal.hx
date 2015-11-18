package unreal;

@:glueCppIncludes("Engine.h")
@:noCopy @:noEquals @:uextern extern class FObjectInitializer {
  public static function Get() : PRef<FObjectInitializer>;
  @:typeName public function CreateDefaultSubobject<T>(Outer:UObject, SubojectName:FName, bTransient:Bool) : PExternal<T>;
}