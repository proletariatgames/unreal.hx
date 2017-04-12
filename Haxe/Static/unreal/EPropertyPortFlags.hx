package unreal;

@:uextern
@:enum abstract EPropertyPortFlags(Int) from Int to Int {
  /** No special property exporint flags */
  var PPF_None = 0x00000000;

  /** Indicates that property data should be treated as text */
  var PPF_Localized = 0x00000001;

  /** Indicates that property data should be wrapped in quotes (for some types of properties) */
  var PPF_Delimited = 0x00000002;

  /** Indicates that the object reference should be verified */
  var PPF_CheckReferences = 0x00000004;

  var PPF_ExportsNotFullyQualified = 0x00000008;

  var PPF_AttemptNonQualifiedSearch = 0x00000010;

  /** Indicates that importing values for config or localized properties is disallowed */
  var PPF_RestrictImportTypes = 0x00000020;

  //                = 0x00000040,
  //                = 0x00000080,

  /** only include properties which are marked CPF_InstancedReference */
  var PPF_SubobjectsOnly = 0x00000100;

  /**
   * Only applicable to component properties (for now)
   * Indicates that two object should be considered identical
   * if the property values for both objects are all identical
   */
  var PPF_DeepComparison = 0x00000200;

  /**
   * Similar to PPF_DeepComparison, except that template components are always compared using standard object
   * property comparison logic (basically if the pointers are different, then the property isn't identical)
   */
  var PPF_DeepCompareInstances = 0x00000400;

  /**
   * Set if this operation is copying in memory (for copy/paste) instead of exporting to a file. There are
   * some subtle differences between the two
   */
  var PPF_Copy = 0x00000800;

  /** Set when duplicating objects via serialization */
  var PPF_Duplicate = 0x00001000;

  /** Indicates that object property values should be exported without the package or class information */
  var PPF_SimpleObjectText = 0x00002000;

  /** parsing default properties - allow text for transient properties to be imported - also modifies ObjectProperty importing slightly for subobjects */
  var PPF_ParsingDefaultProperties = 0x00008000;

  /** indicates that non-categorized transient properties should be exported (by default, they would not be) */
  var PPF_IncludeTransient = 0x00020000;

  /** modifies behavior of UProperty::Identical - indicates that the comparison is between an object and its archetype */
  var PPF_DeltaComparison = 0x00040000;

  /** indicates that we're exporting properties for display in the property window. - used to hide EditHide items in collapsed structs */
  var PPF_PropertyWindow = 0x00080000;

  var PPF_NoInternalArcheType = 0x00100000;

  /** Force fully qualified object names (for debug dumping) */
  var PPF_DebugDump = 0x00200000;

  /** Set when duplicating objects for PIE */
  var PPF_DuplicateForPIE = 0x00400000;

  /** Set when exporting just an object declaration, to be followed by another call with PPF_SeparateDefine */
  var PPF_SeparateDeclare = 0x00800000;

  /** Set when exporting just an object definition, preceded by another call with PPF_SeparateDeclare */
  var PPF_SeparateDefine = 0x01000000;

  /** Used by 'watch value' while blueprint debugging*/
  var PPF_BlueprintDebugView = 0x02000000;

  /** Exporting properties for console variables. */
  var PPF_ConsoleVariable = 0x04000000;

  /** Ignores CPF_Deprecated flag */
  var PPF_UseDeprecatedProperties = 0x08000000;

  /** Export in C++ form */
  var PPF_ExportCpp = 0x10000000;

  @:extern inline private function t() {
    return this;
  }

  @:op(A | B) @:extern inline public function add(flag:EPropertyPortFlags):EPropertyPortFlags {
    return this | flag.t();
  }

  @:op(A & B) @:extern inline public function and(mask:EPropertyPortFlags):EPropertyPortFlags {
    return this & mask.t();
  }
}
