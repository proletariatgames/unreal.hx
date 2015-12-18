package unreal;

@:glueCppIncludes('UObject/UObjectThreadContext.h')
@:uextern extern class FUObjectThreadContext {
  public static function Get():PRef<FUObjectThreadContext>;

  /** Imports for EndLoad optimization.	*/
  public var ImportCount:Int32;
  /** Forced exports for EndLoad optimization. */
  public var ForcedExportCount:Int32;
  /** Count for BeginLoad multiple loads.	*/
  public var ObjBeginLoadCount:Int32;
  /** Objects that might need preloading. */
  public var ObjLoaded:TArray<UObject>;
  /** List of linkers that we want to close the loaders for (to free file handles) - needs to be delayed until EndLoad is called with GObjBeginLoadCount of 0 */
  // public var DelayedLinkerClosePackages:TArray<FLinkerLoad*>;
  /** true when we are routing ConditionalPostLoad/PostLoad to objects										*/
  public var IsRoutingPostLoad:Bool;
  /** true when FLinkerManager deletes linkers */
  public var IsDeletingLinkers:Bool;
  /* Global flag so that FObjectFinders know if they are called from inside the UObject constructors or not. */
  public var IsInConstructor:Int32;
  /* Object that is currently being constructed with ObjectInitializer */
  public var ConstructedObject:UObject;
  /** Points to the main UObject currently being serialized */
  public var SerializedObject:UObject;
  /** Points to the main PackageLinker currently being serialized (Defined in Linker.cpp) */
  // public var SerializedPackageLinker:FLinkerLoad*;
  /** The main Import Index currently being used for serialization by CreateImports() (Defined in Linker.cpp) */
  public var SerializedImportIndex:Int32;
  /** Points to the main Linker currently being used for serialization by CreateImports() (Defined in Linker.cpp) */
  // public var SerializedImportLinker:FLinkerLoad*;
  /** The most recently used export Index for serialization by CreateExport() */
  public var SerializedExportIndex:Int32;
  /** Points to the most recently used Linker for serialization by CreateExport() */
  // public var SerializedExportLinker:FLinkerLoad*;
}
