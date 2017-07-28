package unreal;

@:glueCppIncludes("UObject/UObjectGlobals.h")
@:noCopy @:noEquals @:uextern extern class FObjectInitializer {
  public static function Get() : PRef<FObjectInitializer>;

  @:thisConst
  @:noTemplate
  public function CreateDefaultSubobject<T : UObject>(Outer:UObject, SubojectName:FName, ReturnType:UClass, @:opt(ReturnType) ?ClassToCreateByDefault:UClass, bIsRequired:Bool=true, bAbstract:Bool=false, bIsTransient:Bool=false):T;

  @:thisConst
  @:uname("CreateDefaultSubobject")
  @:typeName public function CreateDefaultSubobject_Template<T>(Outer:UObject, SubojectName:FName, bTransient:Bool=false) : PPtr<T>;

  @:thisConst
  @:typeName public function SetDefaultSubobjectClass<T>(SubojectName:FName) : Const<PRef<FObjectInitializer>>;
}
