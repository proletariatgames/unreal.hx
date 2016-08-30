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
  public function GetDesc():FString;

  /**
    Returns the name of this object (with no path information) Name of the object.
   **/
  public function GetName() : FString;

	/**
	 * Returns the fully qualified pathname for this object as well as the name of the class, in the format:
	 * 'ClassName Outermost[.Outer].Name'.
	 *
	 * @param	StopOuter	if specified, indicates that the output string should be relative to this object.  if StopOuter
	 *						does not exist in this object's Outer chain, the result would be the same as passing NULL.
	 *
	 * @note	safe to call on NULL object pointers!
	 */
  @:thisConst
	public function GetFullName( StopOuter:Const<UObject> ) : FString;

  /**
    Rename this object to a unique name.
   **/
  public function Rename(newName:TCharStar, newOuter:UObject, flags:Int):Bool;

  /**
   * Returns the unique ID of the object...these are reused so it is only unique while the object is alive.
   * Useful as a tag.
  **/
  @:thisConst public function GetUniqueID():unreal.FakeUInt32;

  /**
    Get the default config filename for the specified UObject
   **/
  @:final public function GetDefaultConfigFilename():FString;

  /**
    Called during async load to determine if PostLoad can be called on the loading thread.
   **/
  @:thisConst public function IsPostLoadThreadSafe():Bool;

  public function BeginDestroy() : Void;

  /**
    Add an object to the root set. This prevents the object and all
    its descendants from being deleted during garbage collection.
  **/
  public function AddToRoot() : Void;

  /**
    Remove an object from the root set.
   **/
  public function RemoveFromRoot() : Void;

  /**
    Do any object-specific cleanup required immediately after loading an object, and immediately after any undo/redo.
   **/
  public function PostLoad():Void;

//#if WITH_ENGINE
  @:thisConst
  public function GetWorld() : UWorld;
//#endif

  @:thisConst
  public function GetLifetimeReplicatedProps(outLifetimeProps:PRef<TArray<FLifetimeProperty>>) : Void;

  public function IsA(uclass:UClass) : Bool;

  public function GetOutermost():UPackage;

  public function GetOuter():UObject;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function IsGarbageCollecting():Bool;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function CollectGarbage(keepFlags:EObjectFlags, performFullPurge:Bool):Void;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject")
  @:typeName
  @:global public static function NewObject<T>():PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject")
  @:typeName
  @:global public static function NewObjectByClass<T>(outer:UObject, uclass:UClass):PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject")
  @:typeName
  @:global public static function NewObjectWithFlags<T>(outer:UObject, uclass:UClass, name:FName, flags:EObjectFlags):PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function GetTransientPackage():UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function StaticDuplicateObject(sourceObject:UObject, destOuter:UObject, destName:TCharStar):UObject;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:typeName @:global public static function FindObject<T>(outer:UObject, name:TCharStar) : PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:typeName @:global public static function LoadObject<T>(outer:UObject, name:TCharStar, filename:TCharStar, loadFlags:Int, sandbox:UPackageMap) : PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("GetDefault")
  @:typeName
  @:global public static function GetDefault<T>():PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function FindPackage(inOuter:UObject, packageName:TCharStar):UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function LoadPackage(inOuter:UPackage, packageLongName:TCharStar, loadFlags:Int):UPackage;

  @:glueCppIncludes("UObject/UObjectHash.h")
  @:global public static function GetObjectsWithOuter(inOuter:UObject, results:PRef<TArray<UObject>>, includeNestedObjects:Bool /* = true */, exclusionFlags:EObjectFlags /* = RF_NoFlags */):Void;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function StaticLoadClass(baseClass:UClass, inOuter:UObject, name:TCharStar, filename:TCharStar /* = null */, loadFlags:Int32 /* = 0 */, sandbox:UPackageMap /* = null */):UClass;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function CreatePackage(outer:UObject, packageName:TCharStar):UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function MakeUniqueObjectName(outer:UObject, cls:UClass, baseName:FName):FName;

  public function PostEditImport() : Void;

  public function PostDuplicate(bDuplicateForPIE:Bool):Void;

#if WITH_EDITOR
  public function PreEditChange(PropertyAboutToChange:UProperty) : Void;
	public function PostEditChangeProperty( PropertyChangedEvent:PRef<FPropertyChangedEvent>) : Void;
#end // WITH_EDITOR
}
