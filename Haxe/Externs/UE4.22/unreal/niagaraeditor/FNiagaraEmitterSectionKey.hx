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
package unreal.niagaraeditor;

/**
  Defines data for keys in this emitter section.
**/
@:umodule("NiagaraEditor")
@:glueCppIncludes("Private/Sequencer/NiagaraSequence/Sections/MovieSceneNiagaraEmitterSection.h")
@:noCopy @:noEquals @:uextern @:ustruct extern class FNiagaraEmitterSectionKey {
  @:uproperty public var Value : unreal.niagara.FNiagaraVariable;
  @:uproperty public var ModuleId : unreal.FGuid;
  
}