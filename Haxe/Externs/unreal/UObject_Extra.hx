package unreal;

extern class UObject_Extra {

  /**
   * NOTE: Actually from UObjectBaseUtility class
   * Checks the RF_PendingKill flag to see if it is dead but memory still valid
   */
  @:uexpose()
  @:thisConst
  public function IsPendingKill() : Bool;

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

  public function BeginDestroy() : Void;

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
  @:typeName
  @:global public static function NewObject<T>():PExternal<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject")
  @:typeName
  @:global public static function NewObjectByClass<T>(outer:UObject, uclass:UClass):PExternal<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function GetTransientPackage():UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function StaticDuplicateObject(sourceObject:UObject, destOuter:UObject, destName:TCharStar):UObject;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:typeName @:global public static function LoadObject<T>(outer:UObject, name:TCharStar, filename:TCharStar, loadFlags:Int, sandbow:UPackageMap) : PExternal<T>;

  public function PostEditImport() : Void;

#if WITH_EDITOR
  public function PreEditChange(PropertyAboutToChange:UProperty) : Void;
	public function PostEditChangeProperty( PropertyChangedEvent:PRef<FPropertyChangedEvent>) : Void;
#end // WITH_EDITOR
}
