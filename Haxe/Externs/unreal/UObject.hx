package unreal;

/**
  The main Unreal Object class
 **/
 @:glueCppIncludes("UObject/UObject.h")
@:uextern extern class UObject {
  /**
    Returns true if this object is considered an asset.
   **/
  public function IsAsset():Bool;

  public function GetClass():UClass;

  /**
    A one line description of an object for viewing in the thumbnail view of the generic browser
   **/
  public function GetDesc():FString;

  /**
    Get the default config filename for the specified UObject
   **/
  @:final public function GetDefaultConfigFilename():FString;

  /**
    Called during async load to determine if PostLoad can be called on the loading thread.
   **/
  @:thisConst public function IsPostLoadThreadSafe():Bool;

  /**
    Do any object-specific cleanup required immediately after loading an object, and immediately after any undo/redo.
   **/
  public function PostLoad():Void;

//#if WITH_ENGINE
  @:thisConst
  public function GetWorld() : UWorld;
//#endif

 @:thisConst
 public function GetLifetimeReplicatedProps(outLifetimeProps:PRef<TArray<PStruct<FLifetimeProperty>>>) : Void;


  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function IsGarbageCollecting():Bool;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function NewObject<T>():PExternal<T>;
}
