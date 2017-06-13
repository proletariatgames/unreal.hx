package unreal.editor;

@:glueCppIncludes("EditorReimportHandler.h")
@:noCopy @:noEquals
@:uextern extern class FReimportManager {
  static function Instance():PPtr<FReimportManager>;
  function CanReimport(obj:UObject):Bool;
  function Reimport(obj:UObject, askForNewFileIfMissing:Bool /* = false */, showNotification:Bool /* = false */):Bool;
}
