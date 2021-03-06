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
package unreal.scriptplugin;

/**
  Script-extendable component class
**/
@:umodule("ScriptPlugin")
@:glueCppIncludes("ScriptContextComponent.h")
@:uextern @:uclass extern class UScriptContextComponent extends unreal.UActorComponent {
  
  /**
    Calls a script-defined function (no arguments)
    @param FunctionName Name of the function to call
  **/
  @:ufunction(BlueprintCallable) @:final public function CallScriptFunction(FunctionName : unreal.FString) : Void;
  
}
