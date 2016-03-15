package unreal.editor;

@:glueCppIncludes("EditorReimportHandler.h")
@:uextern extern class FReimportHandler {
  @:uname("new") public static function create():PHaxeCreated<FReimportHandler>;

  function CanReimport(obj:UObject, outFilenames:PRef<TArray<FString>>):Bool;
  function SetReimportPaths(obk:UObject, newReimportPaths:Const<PRef<TArray<FString>>>):Void;
}
