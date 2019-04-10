package unreal.editor;
import unreal.FTimerManager;

@:glueCppIncludes('Editor/EditorEngine.h')
@:uname('UEditorEngine.FBlueprintReinstanced')
typedef FBlueprintReinstanced = MulticastDelegate<FBlueprintReinstanced, Void->Void>;

@:glueCppIncludes('Editor/EditorEngine.h')
@:uname('UEditorEngine.FObjectReimported')
typedef FObjectReimported = MulticastDelegate<FObjectReimported, UObject->Void>;

extern class UEditorEngine_Extra {
  @:glueCppIncludes('Editor.h')
  @:global public static var GEditor:UEditorEngine;

  function SavePackage(inOuter:UPackage, base:UObject, topLevelFlags:EObjectFlags, filename:TCharStar):Bool;

	/** Called by the blueprint compiler after a blueprint has been compiled and all instances replaced, but prior to garbage collection. */
  function OnBlueprintReinstanced():PRef<FBlueprintReinstanced>;
  function BroadcastBlueprintReinstanced():Void;

  /** Called when an object is reimported. */
  function OnObjectReimported():PRef<FObjectReimported>;

  function GetTimerManager():TSharedRef<FTimerManager>;
}
