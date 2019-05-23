package unreal;

extern class UObject_Extra {

  /**
   * NOTE: Actually from UObjectBaseUtility class
   * Checks the RF_PendingKill flag to see if it is dead but memory still valid
   */
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
  public function GetFName() : FName;

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

  // this is final because overriding it in Haxe is not allowed
  @:final public function BeginDestroy() : Void;

  public function ConditionalBeginDestroy() : Void;

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
	 * Called after the C++ constructor and after the properties have been initialized, including those loaded from config.
	 * mainly this is to emulate some behavior of when the constructor was called after the properties were initialized.
	 */
	public function PostInitProperties() : Void;


  /**
    Do any object-specific cleanup required immediately after loading an object, and immediately after any undo/redo.
   **/
  public function PostLoad():Void;

	/**
	 * Instances components for objects being loaded from disk, if necessary.  Ensures that component references
	 * between nested components are fixed up correctly.
	 *
	 * @param	OuterInstanceGraph	when calling this method on subobjects, specifies the instancing graph which contains all instanced
	 *								subobjects and components for a subobject root.
	 */
  public function PostLoadSubobjects(OuterInstanceGraph:PPtr<unreal.FObjectInstancingGraph>) : Void;

  public function ConditionalPostLoad():Void;

  @:thisConst
  public function GetWorld() : UWorld;

  @:thisConst
  public function GetLifetimeReplicatedProps(outLifetimeProps:PRef<TArray<FLifetimeProperty>>) : Void;

  public function IsA(uclass:UClass) : Bool;

  public function IsUnreachable() : Bool;

  public function GetOutermost():UPackage;

  public function GetOuter():UObject;

  @:thisConst public function GetPathName(StopOuter:UObject=null):FString;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function IsGarbageCollecting():Bool;

  @:glueCppIncludes("CoreGlobals.h")
  @:global public static var GExitPurge:Bool;

  @:glueCppIncludes("CoreGlobals.h")
  @:global public static var GIsRequestingExit:Bool;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function CollectGarbage(keepFlags:EObjectFlags, performFullPurge:Bool):Void;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject")
  @:typeName
  @:global public static function NewObjectTemplate<T>():PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("NewObject<UObject>")
  @:noTemplate
  @:typeName @:global public static function NewObject<T : UObject>(outer:UObject, uclass:UClass, ?name:FName, ?flags:EObjectFlags=EObjectFlags.RF_NoFlags, ?objTemplate:UObject, bCopyTransientsFromClassDefaults:Bool=false):T;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function GetTransientPackage():UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function StaticDuplicateObject(sourceObject:UObject, destOuter:UObject, destName:TCharStar):UObject;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("DuplicateObject<UObject>")
  @:noTemplate
  @:global public static function DuplicateObject<T : UObject>(sourceObject:T, destOuter:UObject, ?name:FName):T;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:noTemplate
  @:uname("FindObject<UObject>")
  @:typeName @:global public static function FindObject<T : UObject>(outer:UObject, name:TCharStar, ?exactClass:Bool=false) : T;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:noTemplate
  @:uname("LoadObject<UObject>")
  @:typeName @:global public static function LoadObject<T : UObject>(outer:UObject, name:TCharStar, ?filename:TCharStar, loadFlags:Int=0, ?sandbox:UPackageMap) : T;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:uname("GetDefault")
  @:typeName
  @:global public static function GetDefault<T>():PPtr<T>;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function FindPackage(inOuter:UObject, packageName:TCharStar):UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function LoadPackage(inOuter:UPackage, packageLongName:TCharStar, loadFlags:Int):UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function LoadPackageAsync(InName:PRef<Const<FString>>, InGuid:PPtr<Const<FGuid>>=null, InPackageToLoadFrom:Const<TCharStar>=null, @:opt(new FLoadPackageAsyncDelegate()) ?InCompletionDelegate:FLoadPackageAsyncDelegate, InFlags:EPackageFlags=PKG_None, InPIEInstanceID:Int32=-1, InPackagePriority:Int32=0) : Int32;

  @:glueCppIncludes("UObject/UObjectHash.h")
  @:global public static function GetObjectsWithOuter(inOuter:UObject, results:PRef<TArray<UObject>>, includeNestedObjects:Bool = true, exclusionFlags:EObjectFlags = RF_NoFlags):Void;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function StaticLoadClass(baseClass:UClass, inOuter:UObject, name:TCharStar, filename:TCharStar = null, loadFlags:Int32 = 0, sandbox:UPackageMap = null):UClass;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function CreatePackage(outer:UObject, packageName:TCharStar):UPackage;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function MakeUniqueObjectName(outer:UObject, cls:UClass, baseName:FName):FName;

  @:noTemplate
  public function CreateDefaultSubobject<T : UObject>(SubojectFName:FName, ReturnType:UClass, @:opt(ReturnType) ?ClassToCreateByDefault:UClass, bIsRequired:Bool=true, bAbstract:Bool=false, bIsTransient:Bool=false):T;

  @:typeName
  @:uname("CreateDefaultSubobject")
  public function CreateDefaultSubobject_Template<T : UObject>(SubobjectName:FName, bTransient:Bool = false):T;

  /**
   * Fast version of StaticFindObject that relies on the passed in FName being the object name
   * without any group/ package qualifiers.
   *
   * @param Class                   The to be found object's class
   * @param InOuter                 The to be found object's outer
   * @param InName                  The to be found object's class
   * @param ExactClass              Whether to require an exact match with the passed in class
   * @param AnyPackage              Whether to look in any package
   * @param ExclusiveFlags          Ignores objects that contain any of the specified exclusive flags
   * @param ExclusiveInternalFlags  Ignores objects that contain any of the specified internal exclusive flags
   *
   * @return   Returns a pointer to the found object or NULL if none could be found
   */
  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:keep @:global public static function StaticFindObjectFast(Class:UClass, InOuter:UObject, InName:FName, ExactClass:Bool = false, AnyPackage:Bool = false, ExclusiveFlags:EObjectFlags = RF_NoFlags):UObject;

  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function StaticFindObject(Class:UClass, InOuter:UObject, Name:TCharStar, ExactClass:Bool = false):UObject;

  @:glueCppIncludes("UObject/CoreNet.h")
  @:global public static function RPC_ValidateFailed(Reason:Const<TCharStar>):Void;

/**
 * Create a new instance of an object.  The returned object will be fully initialized.  If InFlags contains RF_NeedsLoad (indicating that the object still needs to load its object data from disk), components
 * are not instanced (this will instead occur in PostLoad()).  The different between StaticConstructObject and StaticAllocateObject is that StaticConstructObject will also call the class constructor on the object
 * and instance any components.
 *
 * @param  Class   the class of the object to create
 * @param  InOuter   the object to create this object within (the Outer property for the new object will be set to the value specified here).
 * @param  Name    the name to give the new object. If no value (NAME_None) is specified, the object will be given a unique name in the form of ClassName_#.
 * @param  SetFlags  the ObjectFlags to assign to the new object. some flags can affect the behavior of constructing the object.
 * @param  InternalSetFlags  the InternalObjectFlags to assign to the new object. some flags can affect the behavior of constructing the object.
 * @param  Template  if specified, the property values from this object will be copied to the new object, and the new object's ObjectArchetype value will be set to this object.
 *           If NULL, the class default object is used instead.
 * @param  bInCopyTransientsFromClassDefaults - if true, copy transient from the class defaults instead of the pass in archetype ptr (often these are the same)
 * @param  InstanceGraph
 *           contains the mappings of instanced objects and components to their templates
 *
 * @return a pointer to a fully initialized object of the specified class.
 **/
  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function StaticConstructObject_Internal(Class:UClass, @:opt(unreal.UObject.GetTransientPackage()) InOuter:UObject, ?Name:FName, SetFlags:EObjectFlags = RF_NoFlags):UObject;

  public function PostEditImport() : Void;

  public function PostDuplicate(bDuplicateForPIE:Bool):Void;

  public function FindFunction(inName:FName):UFunction;

  public function ProcessEvent(func:UFunction, params:AnyPtr):Void;

  public function ClearFlags(flags:EObjectFlags):Void;
  public function SetFlags(flags:EObjectFlags):Void;
  public function HasAnyFlags(flags:EObjectFlags):Bool;
  public function HasAllFlags(flags:EObjectFlags):Bool;

  /**
	 * Note that the object will be modified.  If we are currently recording into the
	 * transaction buffer (undo/redo), save a copy of this object into the buffer and
	 * marks the package as needing to be saved.
	 *
	 * @param	bAlwaysMarkDirty	if true, marks the package dirty even if we aren't
	 *								currently recording an active undo/redo transaction
	 * @return true if the object was saved to the transaction buffer
	 */
	public function Modify(bAlwaysMarkDirty:Bool=true):Bool;

#if WITH_EDITOR
  public function PreEditChange(PropertyAboutToChange:UProperty) : Void;
  public function PostEditChangeProperty( PropertyChangedEvent:PRef<FPropertyChangedEvent>) : Void;
#end // WITH_EDITOR

  public function MarkPendingKill():Void;

  @:thisConst private function IsSupportedForNetworking():Bool;

  /** IsNameStableForNetworking means an object can be referred to its path name (relative to outer) over the network */
  @:thisConst public function IsNameStableForNetworking() : Bool;

#if (UE_VER >= 4.17)
  @:glueCppIncludes("UObject/UObjectGlobals.h")
  @:global public static function ConstructDynamicType(TypePathName:FName, ConstructionSpecifier:EConstructDynamicType):UObject;
#end

  @:glueCppIncludes("Misc/CoreMisc.h")
  @:global public static function IsRunningDedicatedServer():Bool;

  @:thisConst public function IsTemplate(@:opt(RF_ArchetypeObject|RF_ClassDefaultObject) ?TemplateTypes:EObjectFlags):Bool;

  public function GetPrimaryAssetId() : FPrimaryAssetId;


  /** Always called immediately before properties are received from the remote. */
  public function PreNetReceive() : Void;

  /** Always called immediately after properties are received from the remote. */
  public function PostNetReceive() : Void;

	/** Called right after calling all OnRep notifies (called even when there are no notifies) */
	public function PostRepNotifies() : Void;

	/** Called right before being marked for destruction due to network replication */
	public function PreDestroyFromReplication() : Void;

	public function SaveConfig(@:opt(EPropertyFlags.CPF_Config) ?Flags:EPropertyFlags, ?Filename:TCharStar, @:opt(unreal.FConfigCacheIni.GConfig) ?Config:PPtr<FConfigCacheIni>) : Void;
	public function UpdateDefaultConfigFile(@:opt(new unreal.FString("")) ?SpecificFileLocation:Const<PRef<FString>>) : Void;
	public function UpdateGlobalUserConfigFile() : Void;
}
