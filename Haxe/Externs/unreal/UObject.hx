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
  public function GetDesc():PStruct<FString>;

  /**
    Returns the name of this object (with no path information) Name of the object.
   **/
  public function GetName() : PStruct<FString>;

  /**
    Get the default config filename for the specified UObject
   **/
  @:final public function GetDefaultConfigFilename():PStruct<FString>;

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

 public function IsA(uclass:UClass) : Bool;


  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function IsGarbageCollecting():Bool;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject")
  @:global public static function NewObject<T>():PExternal<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject")
  @:global public static function NewObjectByClass<T>(outer:UObject, uclass:UClass):PExternal<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function GetTransientPackage():UPackage;
}
