package unreal;

/**
  The property flags - see "ObjectMacros.h"
 **/
#if (UE_VER > 4.19)
@:glueCppIncludes("UObject/ObjectMacros.h")
@:uextern @:enum
#end
abstract EPropertyFlags(UInt64) from UInt64 to UInt64 {
  /**
    Property is user-settable in the editor.
   **/
  public static var CPF_Edit(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Edit():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000001);
  }

  /**
    This is a constant function parameter
   **/
  public static var CPF_ConstParm(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_ConstParm():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000002);
  }

  /**
    This property can be read by blueprint code
   **/
  public static var CPF_BlueprintVisible(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_BlueprintVisible():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000004);
  }

  /**
    Object can be exported with actor.
   **/
  public static var CPF_ExportObject(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_ExportObject():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000008);
  }

  /**
    This property cannot be modified by blueprint code
   **/
  public static var CPF_BlueprintReadOnly(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_BlueprintReadOnly():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000010);
  }

  /**
    Property is relevant to network replication.
   **/
  public static var CPF_Net(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Net():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000020);
  }

  /**
    Indicates that elements of an array can be modified, but its size cannot be changed.
   **/
  public static var CPF_EditFixedSize(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_EditFixedSize():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000040);
  }

  /**
    Function/When call parameter.
   **/
  public static var CPF_Parm(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Parm():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000080);
  }

  /**
    Value is copied out after function call.
   **/
  public static var CPF_OutParm(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_OutParm():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000100);
  }

  /**
    memset is fine for construction
   **/
  public static var CPF_ZeroConstructor(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_ZeroConstructor():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000200);
  }

  /**
    Return value.
   **/
  public static var CPF_ReturnParm(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_ReturnParm():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000400);
  }

  /**
    Disable editing of this property on an archetype/sub-blueprint
   **/
  public static var CPF_DisableEditOnTemplate(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_DisableEditOnTemplate():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00000800);
  }

  /**
    Property is transient: shouldn't be saved, zero-filled at load time.
   **/
  public static var CPF_Transient(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Transient():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00002000);
  }

  /**
    Property should be loaded/saved as permanent profile.
   **/
  public static var CPF_Config(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Config():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00004000);
  }


  /**
    Disable editing on an instance of this class
   **/
  public static var CPF_DisableEditOnInstance(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_DisableEditOnInstance():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00010000);
  }

  /**
    Property is uneditable in the editor.
   **/
  public static var CPF_EditConst(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_EditConst():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00020000);
  }

  /**
    Load config from base class, not subclass.
   **/
  public static var CPF_GlobalConfig(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_GlobalConfig():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00040000);
  }

  /**
    Property is a component references.
   **/
  public static var CPF_InstancedReference(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_InstancedReference():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00080000);
  }


  /**
    Property should always be reset to the default value during any type of duplication (copy/paste, binary duplication, etc.)
   **/
  public static var CPF_DuplicateTransient(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_DuplicateTransient():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00200000);
  }

  /**
    Property contains subobject references (TSubobjectPtr)
   **/
  public static var CPF_SubobjectReference(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_SubobjectReference():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x00400000);
  }


  /**
    Property should be serialized for save games
   **/
  public static var CPF_SaveGame(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_SaveGame():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x01000000);
  }

  /**
    Hide clear (and browse) button.
   **/
  public static var CPF_NoClear(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_NoClear():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x02000000);
  }


  /**
    Value is passed by reference; CPF_OutParam and CPF_Param should also be set.
   **/
  public static var CPF_ReferenceParm(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_ReferenceParm():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x08000000);
  }

  /**
    MC Delegates only.  Property should be exposed for assigning in blueprint code
   **/
  public static var CPF_BlueprintAssignable(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_BlueprintAssignable():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x10000000);
  }

  /**
    Property is deprecated.  Read it from an archive, but don't save it.
   **/
  public static var CPF_Deprecated(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Deprecated():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x20000000);
  }

  /**
    If this is set, then the property can be memcopied instead of CopyCompleteValue / CopySingleValue
   **/
  public static var CPF_IsPlainOldData(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_IsPlainOldData():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x40000000);
  }

  /**
    Not replicated. For non replicated properties in replicated structs
   **/
  public static var CPF_RepSkip(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_RepSkip():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000000, 0x80000000);
  }

  /**
    Notify actors when a property is replicated
   **/
  public static var CPF_RepNotify(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_RepNotify():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000001, 0x00000000);
  }

  /**
    interpolatable property for use with matinee
   **/
  public static var CPF_Interp(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Interp():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000002, 0x00000000);
  }

  /**
    Property isn't transacted
   **/
  public static var CPF_NonTransactional(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_NonTransactional():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000004, 0x00000000);
  }

  /**
    Property should only be loaded in the editor
   **/
  public static var CPF_EditorOnly(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_EditorOnly():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000008, 0x00000000);
  }

  /**
    No destructor
   **/
  public static var CPF_NoDestructor(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_NoDestructor():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000010, 0x00000000);
  }


  /**
    Only used for weak pointers, means the export type is autoweak
   **/
  public static var CPF_AutoWeak(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_AutoWeak():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000040, 0x00000000);
  }

  /**
    Property contains component references.
   **/
  public static var CPF_ContainsInstancedReference(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_ContainsInstancedReference():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000080, 0x00000000);
  }

  /**
    asset instances will add properties with this flag to the asset registry automatically
   **/
  public static var CPF_AssetRegistrySearchable(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_AssetRegistrySearchable():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000100, 0x00000000);
  }

  /**
    The property is visible by default in the editor details view
   **/
  public static var CPF_SimpleDisplay(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_SimpleDisplay():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000200, 0x00000000);
  }

  /**
    The property is advanced and not visible by default in the editor details view
   **/
  public static var CPF_AdvancedDisplay(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_AdvancedDisplay():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000400, 0x00000000);
  }

  /**
    property is protected from the perspective of script
   **/
  public static var CPF_Protected(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_Protected():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00000800, 0x00000000);
  }

  /**
    MC Delegates only.  Property should be exposed for calling in blueprint code
   **/
  public static var CPF_BlueprintCallable(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_BlueprintCallable():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00001000, 0x00000000);
  }

  /**
    MC Delegates only.  This delegate accepts (only in blueprint) only events with BlueprintAuthorityOnly.
   **/
  public static var CPF_BlueprintAuthorityOnly(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_BlueprintAuthorityOnly():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00002000, 0x00000000);
  }

  /**
    Property shouldn't be exported to text format (e.g. copy/paste)
   **/
  public static var CPF_TextExportTransient(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_TextExportTransient():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00004000, 0x00000000);
  }

  /**
    Property should only be copied in PIE
   **/
  public static var CPF_NonPIEDuplicateTransient(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_NonPIEDuplicateTransient():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00008000, 0x00000000);
  }

  /**
    Property is exposed on spawn
   **/
  public static var CPF_ExposeOnSpawn(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_ExposeOnSpawn():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00010000, 0x00000000);
  }

  /**
    A object referenced by the property is duplicated like a component. (Each actor should have an own instance.)
   **/
  public static var CPF_PersistentInstance(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_PersistentInstance():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00020000, 0x00000000);
  }

  /**
    Property was parsed as a wrapper class like TSubobjectOf<T>, FScriptInterface etc., rather than a USomething*
   **/
  public static var CPF_UObjectWrapper(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_UObjectWrapper():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00040000, 0x00000000);
  }

  /**
    This property can generate a meaningful hash value.
   **/
  public static var CPF_HasGetValueTypeHash(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_HasGetValueTypeHash():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00080000, 0x00000000);
  }

  /**
    Public native access specifier
   **/
  public static var CPF_NativeAccessSpecifierPublic(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_NativeAccessSpecifierPublic():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00100000, 0x00000000);
  }

  /**
    Protected native access specifier
   **/
  public static var CPF_NativeAccessSpecifierProtected(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_NativeAccessSpecifierProtected():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00200000, 0x00000000);
  }

  /**
    Private native access specifier
   **/
  public static var CPF_NativeAccessSpecifierPrivate(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_NativeAccessSpecifierPrivate():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00400000, 0x00000000);
  }

  /**
    Property shouldn't be serialized, can still be exported to text
   **/
  public static var CPF_SkipSerialization(get, never):EPropertyFlags;
  #if !cppia inline #end static function get_CPF_SkipSerialization():EPropertyFlags {
    return Int64Helpers.makeUnsigned(0x00800000, 0x00000000);
  }

  inline public function t() {
    return this;
  }

  @:op(A&B) inline public function and(b:EPropertyFlags):EPropertyFlags {
    return Int64Helpers.uopAnd(this, b.t());
  }

  @:op(A|B) inline public function or(b:EPropertyFlags):EPropertyFlags {
    return Int64Helpers.uopOr(this, b.t());
  }

  inline public function hasAny(b:EPropertyFlags):Bool {
    return Int64Helpers.uopAnd(this, b.t()) != 0;
  }

  inline public function hasAll(b:EPropertyFlags):Bool {
    return Int64Helpers.uopAnd(this, b.t()) == b.t();
  }
}
