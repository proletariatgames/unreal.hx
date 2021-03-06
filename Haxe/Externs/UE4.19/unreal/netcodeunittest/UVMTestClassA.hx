/**
 * 
 * WARNING! This file was autogenerated by: 
 *  _   _ _   _ __   __ 
 * | | | | | | |\ \ / / 
 * | | | | |_| | \ V /  
 * | | | |  _  | /   \  
 * | |_| | | | |/ /^\ \ 
 *  \___/\_| |_/\/   \/ 
 * 
 * This file was autogenerated by UnrealHxGenerator using UHT definitions.
 * It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
 * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.netcodeunittest;

/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, some of its methods are inaccessible
  
  Test classes for testing different types/combinations of property reflection
**/
@:umodule("NetcodeUnitTest")
@:glueCppIncludes("UnitTests/VMReflection.h")
@:noClass @:uextern @:uclass extern class UVMTestClassA extends unreal.UObject {
  @:uproperty public var DynStructPropArray : unreal.TArray<unreal.FVector>;
  @:uproperty public var StructProp : unreal.FVector;
  @:uproperty public var DynPawnPropArray : unreal.TArray<unreal.APawn>;
  @:uproperty public var DynClassPropArray : unreal.TArray<unreal.UClass>;
  @:uproperty public var DynTextPropArray : unreal.TArray<unreal.FText>;
  @:uproperty public var DynStringPropArray : unreal.TArray<unreal.FString>;
  @:uproperty public var DynUInt64PropArray : unreal.TArray<unreal.FakeUInt64>;
  @:uproperty public var DynUIntPropArray : unreal.TArray<unreal.FakeUInt32>;
  @:uproperty public var DynUInt16PropArray : unreal.TArray<unreal.UInt16>;
  @:uproperty public var DynIntPropArray : unreal.TArray<unreal.Int32>;
  @:uproperty public var DynInt8PropArray : unreal.TArray<unreal.Int8>;
  @:uproperty public var DynInt64PropArray : unreal.TArray<unreal.Int64>;
  @:uproperty public var DynInt16PropArray : unreal.TArray<unreal.Int16>;
  @:uproperty public var DynFloatPropArray : unreal.TArray<unreal.Float32>;
  @:uproperty public var DynDoublePropArray : unreal.TArray<unreal.Float64>;
  @:uproperty public var DynNamePropArray : unreal.TArray<unreal.FName>;
  @:uproperty public var DynObjectPropArray : unreal.TArray<unreal.UObject>;
  @:uproperty public var DynBoolPropArray : unreal.TArray<Bool>;
  @:uproperty public var DynBytePropArray : unreal.TArray<unreal.UInt8>;
  @:uproperty public var TextProp : unreal.FText;
  @:uproperty public var StringProp : unreal.FString;
  @:uproperty public var NameProp : unreal.FName;
  @:uproperty public var bBoolPropE : Bool;
  @:uproperty public var bBoolPropD : Bool;
  @:uproperty public var bBoolPropC : Bool;
  @:uproperty public var bBoolPropB : Bool;
  @:uproperty public var bBoolPropA : Bool;
  @:uproperty public var DoubleProp : unreal.Float64;
  @:uproperty public var FloatProp : unreal.Float32;
  @:uproperty public var Int64Prop : unreal.Int64;
  @:uproperty public var Int32Prop : unreal.Int32;
  @:uproperty public var Int16Prop : unreal.Int16;
  @:uproperty public var Int8Prop : unreal.Int8;
  @:uproperty public var UInt64Prop : unreal.FakeUInt64;
  @:uproperty public var UInt32Prop : unreal.FakeUInt32;
  @:uproperty public var UInt16Prop : unreal.UInt16;
  @:uproperty public var ByteProp : unreal.UInt8;
  @:uproperty public var AObjectRef : unreal.UObject;
  
}
