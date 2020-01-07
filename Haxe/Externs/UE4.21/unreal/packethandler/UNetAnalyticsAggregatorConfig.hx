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
package unreal.packethandler;

/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, some of its methods are inaccessible
  
  Configuration for FNetAnalyticsAggregator - loaded PerObjectConfig, for each NetDriverName
**/
@:umodule("PacketHandler")
@:glueCppIncludes("NetAnalyticsAggregatorConfig.h")
@:noClass @:uextern @:uclass extern class UNetAnalyticsAggregatorConfig extends unreal.UObject {
  
  /**
    Registers FNetAnalyticsData data holders, by DataName - and specifies whether they are enabled or disabled
  **/
  @:uproperty public var NetAnalyticsData : unreal.TArray<unreal.packethandler.FNetAnalyticsDataConfig>;
  
}