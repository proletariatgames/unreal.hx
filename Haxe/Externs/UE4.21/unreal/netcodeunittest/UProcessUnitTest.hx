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
  Base class for all unit tests which launch child processes, whether they be UE4 child processes, or other arbitrary programs.
  
  Handles management of child processes, memory usage tracking, log/stdout output gathering/printing, and crash detection.
**/
@:umodule("NetcodeUnitTest")
@:glueCppIncludes("ProcessUnitTest.h")
@:uextern @:uclass extern class UProcessUnitTest extends unreal.netcodeunittest.UUnitTest {
  
}
