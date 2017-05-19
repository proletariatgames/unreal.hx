package unreal;

extern class UClass_Extra {
  // Class flags; See EClassFlags for more information
  public var ClassFlags:EClassFlags;

  // This is the blueprint that caused the generation of this class, or NULL if it is a native compiled-in class
  public var ClassGeneratedBy:UObject;

  // The required type for the outer of instances of this class.
  public var ClassWithin:UClass;

  public var ClassConfigName:FName;

  // Cast flags used to accelerate dynamic_cast<T*> on objects of this type for common T
  public var ClassCastFlags:UInt64;

  // Class pseudo-unique counter; used to accelerate unique instance name generation
  public var ClassUnique:Int32;

  public function GetSuperClass() : UClass;
  @:global @:typeName
  public static function FindField<T>(Owner:UStruct, FieldName:FName) : PPtr<T>;

  public function FindFunctionByName(name:FName, includeSuper:EIncludeSuperFlag=IncludeSuper) : UFunction;

  public function GetDefaultObject(bCreateIfNeeded:Bool=true) : UObject;

  public function HasAllClassFlags(flags:Int32):Bool;

  /**
   * Assembles the token stream for realtime garbage collection by combining the per class only
   * token stream for each class in the class hierarchy. This is only done once and duplicate
   * work is avoided by using an object flag.
   * @param bForce Assemble the stream even if it has been already assembled (deletes the old one)
   */
  function AssembleReferenceTokenStream(bForce:Bool = false):Void;

  function AddFunctionToFunctionMap(fn:UFunction):Void;
}
