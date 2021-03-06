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
package unreal.nutunrealengine4;

/**
  WARNING: This type was not defined as DLL export on its declaration. Because of that, some of its methods are inaccessible
  
  Tests an RPC crash caused by empty FText's, as reported on the UDN here:
  https://udn.unrealengine.com/questions/213120/using-empty-ftexts-within-rpcs.html
  
  UDN Post: "Using Empty FTexts within RPCs"
  Hey,
  we're using FTexts within RPCs functions (server -> client in my specific case) to pass localized strings.
  That works fine until the point when the server sends an empty FText.
  In that case both the FText members SourceString and DisplayString are null on client side which lead to crashes whenever you use
  something like ToString which assumes those are valid.
  
  Is this the intended behavior? I'm using FTextInspector::GetSourceString(text) to run checks on these replicated FTexts now to catch
  this case. FTexts that are not empty work just fine.
  
  Thanks, Oliver
**/
@:umodule("NUTUnrealEngine4")
@:glueCppIncludes("UnitTests/FTextCrash.h")
@:noClass @:uextern @:uclass extern class UFTextCrash extends unreal.netcodeunittest.UClientUnitTest {
  
}
