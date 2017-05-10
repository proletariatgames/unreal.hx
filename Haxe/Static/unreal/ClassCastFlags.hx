package unreal;

/**
  The class cast flags - see "ObjectMacros.h"
 **/
class ClassCastFlags {

  public static var CASTCLASS_None(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_None():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000000);
  }

  public static var CASTCLASS_UField(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UField():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000001);
  }

  public static var CASTCLASS_UInt8Property(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UInt8Property():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000002);
  }

  public static var CASTCLASS_UEnum(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UEnum():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000004);
  }

  public static var CASTCLASS_UStruct(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UStruct():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000008);
  }

  public static var CASTCLASS_UScriptStruct(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UScriptStruct():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000010);
  }

  public static var CASTCLASS_UClass(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UClass():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000020);
  }

  public static var CASTCLASS_UByteProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UByteProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000040);
  }

  public static var CASTCLASS_UIntProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UIntProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000080);
  }

  public static var CASTCLASS_UFloatProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UFloatProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000100);
  }

  public static var CASTCLASS_UUInt64Property(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UUInt64Property():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000200);
  }

  public static var CASTCLASS_UClassProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UClassProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000400);
  }

  public static var CASTCLASS_UUInt32Property(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UUInt32Property():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000000800);
  }

  public static var CASTCLASS_UInterfaceProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UInterfaceProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000001000);
  }

  public static var CASTCLASS_UNameProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UNameProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000002000);
  }

  public static var CASTCLASS_UStrProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UStrProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000004000);
  }

  public static var CASTCLASS_UProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000008000);
  }

  public static var CASTCLASS_UObjectProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UObjectProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000010000);
  }

  public static var CASTCLASS_UBoolProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UBoolProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000020000);
  }

  public static var CASTCLASS_UUInt16Property(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UUInt16Property():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000040000);
  }

  public static var CASTCLASS_UFunction(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UFunction():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000080000);
  }

  public static var CASTCLASS_UStructProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UStructProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000100000);
  }

  public static var CASTCLASS_UArrayProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UArrayProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000200000);
  }

  public static var CASTCLASS_UInt64Property(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UInt64Property():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000400000);
  }

  public static var CASTCLASS_UDelegateProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UDelegateProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x000800000);
  }

  public static var CASTCLASS_UNumericProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UNumericProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x001000000);
  }

  public static var CASTCLASS_UMulticastDelegateProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UMulticastDelegateProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x002000000);
  }

  public static var CASTCLASS_UObjectPropertyBase(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UObjectPropertyBase():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x004000000);
  }

  public static var CASTCLASS_UWeakObjectProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UWeakObjectProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x008000000);
  }

  public static var CASTCLASS_ULazyObjectProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_ULazyObjectProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x010000000);
  }

  public static var CASTCLASS_UAssetObjectProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UAssetObjectProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x020000000);
  }

  public static var CASTCLASS_UTextProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UTextProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x040000000);
  }

  public static var CASTCLASS_UInt16Property(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UInt16Property():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x080000000);
  }

  public static var CASTCLASS_UDoubleProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UDoubleProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x100000000);
  }

  public static var CASTCLASS_UAssetClassProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UAssetClassProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x200000000);
  }

  public static var CASTCLASS_UPackage(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UPackage():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x400000000);
  }

  public static var CASTCLASS_ULevel(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_ULevel():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000000,0x800000000);
  }

  public static var CASTCLASS_AActor(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_AActor():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000001,0x000000000);
  }

  public static var CASTCLASS_APlayerController(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_APlayerController():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000002,0x000000000);
  }

  public static var CASTCLASS_APawn(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_APawn():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000004,0x000000000);
  }

  public static var CASTCLASS_USceneComponent(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_USceneComponent():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000008,0x000000000);
  }

  public static var CASTCLASS_UPrimitiveComponent(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UPrimitiveComponent():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000010,0x000000000);
  }

  public static var CASTCLASS_USkinnedMeshComponent(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_USkinnedMeshComponent():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000020,0x000000000);
  }

  public static var CASTCLASS_USkeletalMeshComponent(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_USkeletalMeshComponent():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000040,0x000000000);
  }

  public static var CASTCLASS_UBlueprint(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UBlueprint():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000080,0x000000000);
  }

  public static var CASTCLASS_UDelegateFunction(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UDelegateFunction():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000100,0x000000000);
  }

  public static var CASTCLASS_UStaticMeshComponent(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UStaticMeshComponent():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000200,0x000000000);
  }

  public static var CASTCLASS_UMapProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_UMapProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000400,0x000000000);
  }

  public static var CASTCLASS_USetProperty(get, never):UInt64;
  #if !cppia inline #end static function get_CASTCLASS_USetProperty():UInt64 {
    return Int64Helpers.makeUnsigned(0x0000800,0x000000000);
  }
}
