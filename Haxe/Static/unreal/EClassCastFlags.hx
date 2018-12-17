package unreal;

/**
  The class cast flags - see "ObjectMacros.h"
 **/
#if (UE_VER > 4.19)
@:glueCppIncludes("UObject/ObjectMacros.h")
@:uextern @:enum
#end
abstract EClassCastFlags(UInt64) from UInt64 to UInt64 {

  public static var CASTCLASS_None(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_None():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000000);
  }

  public static var CASTCLASS_UField(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UField():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000001);
  }

  public static var CASTCLASS_UInt8Property(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UInt8Property():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000002);
  }

  public static var CASTCLASS_UEnum(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UEnum():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000004);
  }

  public static var CASTCLASS_UStruct(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UStruct():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000008);
  }

  public static var CASTCLASS_UScriptStruct(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UScriptStruct():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000010);
  }

  public static var CASTCLASS_UClass(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UClass():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000020);
  }

  public static var CASTCLASS_UByteProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UByteProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000040);
  }

  public static var CASTCLASS_UIntProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UIntProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000080);
  }

  public static var CASTCLASS_UFloatProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UFloatProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000100);
  }

  public static var CASTCLASS_UUInt64Property(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UUInt64Property():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000200);
  }

  public static var CASTCLASS_UClassProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UClassProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000400);
  }

  public static var CASTCLASS_UUInt32Property(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UUInt32Property():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00000800);
  }

  public static var CASTCLASS_UInterfaceProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UInterfaceProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00001000);
  }

  public static var CASTCLASS_UNameProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UNameProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00002000);
  }

  public static var CASTCLASS_UStrProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UStrProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00004000);
  }

  public static var CASTCLASS_UProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00008000);
  }

  public static var CASTCLASS_UObjectProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UObjectProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00010000);
  }

  public static var CASTCLASS_UBoolProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UBoolProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00020000);
  }

  public static var CASTCLASS_UUInt16Property(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UUInt16Property():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00040000);
  }

  public static var CASTCLASS_UFunction(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UFunction():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00080000);
  }

  public static var CASTCLASS_UStructProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UStructProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00100000);
  }

  public static var CASTCLASS_UArrayProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UArrayProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00200000);
  }

  public static var CASTCLASS_UInt64Property(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UInt64Property():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00400000);
  }

  public static var CASTCLASS_UDelegateProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UDelegateProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x00800000);
  }

  public static var CASTCLASS_UNumericProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UNumericProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x01000000);
  }

  public static var CASTCLASS_UMulticastDelegateProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UMulticastDelegateProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x02000000);
  }

  public static var CASTCLASS_UObjectPropertyBase(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UObjectPropertyBase():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x04000000);
  }

  public static var CASTCLASS_UWeakObjectProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UWeakObjectProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x08000000);
  }

  public static var CASTCLASS_ULazyObjectProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_ULazyObjectProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x10000000);
  }

  public static var CASTCLASS_UAssetObjectProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UAssetObjectProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x20000000);
  }

  public static var CASTCLASS_UTextProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UTextProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x40000000);
  }

  public static var CASTCLASS_UInt16Property(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UInt16Property():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x0000000,0x80000000);
  }

  public static var CASTCLASS_UDoubleProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UDoubleProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000001,0x00000000);
  }

  public static var CASTCLASS_UAssetClassProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UAssetClassProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000002,0x00000000);
  }

  public static var CASTCLASS_UPackage(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UPackage():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000004,0x00000000);
  }

  public static var CASTCLASS_ULevel(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_ULevel():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000008,0x00000000);
  }

  public static var CASTCLASS_AActor(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_AActor():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000010,0x00000000);
  }

  public static var CASTCLASS_APlayerController(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_APlayerController():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000020,0x00000000);
  }

  public static var CASTCLASS_APawn(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_APawn():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000040,0x00000000);
  }

  public static var CASTCLASS_USceneComponent(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_USceneComponent():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000080,0x00000000);
  }

  public static var CASTCLASS_UPrimitiveComponent(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UPrimitiveComponent():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000100,0x00000000);
  }

  public static var CASTCLASS_USkinnedMeshComponent(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_USkinnedMeshComponent():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000200,0x00000000);
  }

  public static var CASTCLASS_USkeletalMeshComponent(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_USkeletalMeshComponent():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000400,0x00000000);
  }

  public static var CASTCLASS_UBlueprint(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UBlueprint():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00000800,0x00000000);
  }

  public static var CASTCLASS_UDelegateFunction(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UDelegateFunction():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00001000,0x00000000);
  }

  public static var CASTCLASS_UStaticMeshComponent(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UStaticMeshComponent():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00002000,0x00000000);
  }

  public static var CASTCLASS_UMapProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_UMapProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00004000,0x00000000);
  }

  public static var CASTCLASS_USetProperty(get, never):EClassCastFlags;
  #if !cppia inline #end static function get_CASTCLASS_USetProperty():EClassCastFlags {
    return cast Int64Helpers.makeUnsigned(0x00008000,0x00000000);
  }
}
