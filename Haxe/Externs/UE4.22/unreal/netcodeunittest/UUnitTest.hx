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
  Base class for all unit tests
**/
@:umodule("NetcodeUnitTest")
@:glueCppIncludes("UnitTest.h")
@:uextern @:uclass extern class UUnitTest extends unreal.netcodeunittest.UUnitTestBase {
  
  /**
    Whether or not the success or failure of the current unit test has been verified
  **/
  @:uproperty private var VerificationState : unreal.netcodeunittest.EUnitTestVerification;
  
  /**
    UnitTask's which must be run before different stages of the unit test can execute
  **/
  @:uproperty private var UnitTasks : unreal.TArray<unreal.netcodeunittest.UUnitTask>;
  
  /**
    The amount of time it took to execute the unit test the last time it was run
  **/
  @:uproperty public var LastExecutionTime : unreal.Float32;
  
  /**
    The amount of time it takes to reach 'PeakMemoryUsage' (or within 90% of its value)
  **/
  @:uproperty public var TimeToPeakMem : unreal.Float32;
  
  /**
    Stores stats on the highest-ever reported memory usage, for this unit test - for estimating memory usage
  **/
  @:uproperty public var PeakMemoryUsage : unreal.FakeUInt64;
  
}
