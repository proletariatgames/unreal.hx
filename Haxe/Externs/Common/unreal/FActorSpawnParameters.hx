package unreal;

@:glueCppIncludes("Engine/World.h")
@:uextern extern class FActorSpawnParameters
{
  @:uname(".ctor")
  public static function create() : FActorSpawnParameters;
  @:uname("new")
  public static function createNew() : POwnedPtr<FActorSpawnParameters>;

  @:thisConst
  public function IsRemoteOwned() : Bool;

  public var Name:FName;
  public var Template:AActor;
  public var Owner:AActor;
  public var Instigator:APawn;
  public var OverrideLevel:ULevel;
  public var SpawnCollisionHandlingOverride:ESpawnActorCollisionHandlingMethod;
  public var bNoFail:Bool;
  public var bDeferConstruction:Bool;
  public var bAllowDuringConstructionScript:Bool;
}
