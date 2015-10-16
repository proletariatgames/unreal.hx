package unreal;

/**
 * Flags describing an object instance
 */
@:glueCppIncludes("UObject/ObjectBase.h")
@:uextern extern enum EObjectFlags {
  // Do not add new flags unless they truly belong here. There are alternatives.
  // if you change any the bit of any of the RF_Load flags, then you will need legacy serialization
  RF_NoFlags; // = 0x00000000,	///< No flags, used to avoid a cast

  // This first group of flags mostly has to do with what kind of object it is. Other than transient, these are the persistent object flags.
  // The garbage collector also tends to look at these.
  RF_Public; // =0x00000001,	///< Object is visible outside its package.
  RF_Standalone; // =0x00000002,	///< Keep object around for editing even if unreferenced.
  RF_Native; // =0x00000004,	///< Native (UClass only).
  RF_Transactional; // =0x00000008,	///< Object is transactional.
  RF_ClassDefaultObject; // =0x00000010,	///< This object is its class's default object
  RF_ArchetypeObject; // =0x00000020,	///< This object is a template for another object - treat like a class default object
  RF_Transient; // =0x00000040,	///< Don't save object.

  // This group of flags is primarily concerned with garbage collection.
  RF_RootSet; // =0x00000080,	///< Object will not be garbage collected, even if unreferenced.
  RF_Unreachable; // =0x00000100,	///< Object is not reachable on the object graph.
  RF_TagGarbageTemp; // =0x00000200,	///< This is a temp user flag for various utilities that need to use the garbage collector. The garbage collector itself does not interpret it.

  // The group of flags tracks the stages of the lifetime of a uobject
  RF_NeedLoad; // =0x00000400,	///< During load, indicates object needs loading.
  RF_AsyncLoading; // =0x00000800,	///< Object is being asynchronously loaded.
  RF_NeedPostLoad; // =0x00001000,	///< Object needs to be postloaded.
  RF_NeedPostLoadSubobjects; // =0x00002000,	///< During load, indicates that the object still needs to instance subobjects and fixup serialized component references
  RF_PendingKill; // =0x00004000,	///< Objects that are pending destruction (invalid for gameplay but valid objects)
  RF_BeginDestroyed; // =0x00008000,	///< BeginDestroy has been called on the object.
  RF_FinishDestroyed; // =0x00010000,	///< FinishDestroy has been called on the object.

  // Misc. Flags
  RF_BeingRegenerated; // =0x00020000,	///< Flagged on UObjects that are used to create UClasses (e.g. Blueprints) while they are regenerating their UClass on load (See FLinkerLoad::CreateExport())
  RF_DefaultSubObject; // =0x00040000,	///< Flagged on subobjects that are defaults
  RF_WasLoaded; // =0x00080000,	///< Flagged on UObjects that were loaded
  RF_TextExportTransient; // =0x00100000,	///< Do not export object to text form (e.g. copy/paste). Generally used for sub-objects that can be regenerated from data in their parent object.
  RF_LoadCompleted; // =0x00200000,	///< Object has been completely serialized by linkerload at least once. DO NOT USE THIS FLAG, It should be replaced with RF_WasLoaded.
  RF_InheritableComponentTemplate; // = 0x00400000, ///< Archetype of the object can be in its super class
  RF_Async; // = 0x00800000, ///< Object exists only on a different thread than the game thread.
  RF_StrongRefOnFrame; // = 0x01000000,	///< References to this object from persistent function frame are handled as strong ones.
  RF_NoStrongReference; // = 0x02000000,  ///< The object is not referenced by any strong reference. The flag is used by GC.
}

