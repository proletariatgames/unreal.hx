/**
   * 
   * WARNING! This file was autogenerated by: 
   *  _   _ _____     ___   _   _ __   __ 
   * | | | |  ___|   /   | | | | |\ \ / / 
   * | | | | |__    / /| | | |_| | \ V /  
   * | | | |  __|  / /_| | |  _  | /   \  
   * | |_| | |___  \___  | | | | |/ /^\ \ 
   *  \___/\____/      |_/ \_| |_/\/   \/ 
   * 
   * This file was autogenerated by UE4HaxeExternGenerator using UHT definitions. It only includes UPROPERTYs and UFUNCTIONs. Do not modify it!
   * In order to add more definitions, create or edit a type with the same name/package, but with an `_Extra` suffix
**/
package unreal.blueprintgraph;


/**
  WARNING: This type was defined as MinimalAPI on its declaration. Because of that, its properties/methods are inaccessible
  
  
**/
@:umodule("BlueprintGraph")
@:glueCppIncludes("K2Node_FunctionTerminator.h")
@:uextern @:uclass extern class UK2Node_FunctionTerminator extends unreal.blueprintgraph.UK2Node_EditablePinBase {
  
  /**
    The name of the signature function.
  **/
  @:uproperty public var SignatureName : unreal.FName;
  
  /**
    The source class that defines the signature, if it is getting that from elsewhere (e.g. interface, base class etc).
    If NULL, this is a newly created function.
  **/
  @:uproperty public var SignatureClass : unreal.TSubclassOf<unreal.UObject>;
  
}